locals {
  redis_credentials = {
    host     = var.redis_credentials.host,
    password = var.redis_credentials.password,
    port     = var.redis_credentials.port,
  }
}

resource "aws_lb" "cas_ui" {
  name               = "${var.resource_name_prefixes.hyphens}-ALB-CASUI"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cas_ui_lb.id]
  subnets            = var.subnets.public.ids

  drop_invalid_header_fields = var.drop_invalid_header_fields

  enable_deletion_protection = var.lb_enable_deletion_protection

  access_logs {
    bucket  = var.logs_bucket_id
    prefix  = "access-logs/casui"
    enabled = var.enable_lb_access_logs
  }

  connection_logs {
    bucket  = var.logs_bucket_id
    prefix  = "connection-logs/casui"
    enabled = var.enable_lb_connection_logs
  }

  tags = {
    WAF_ENABLED = var.cas_ui_lb_waf_enabled == true ? true : null
  }
}

resource "aws_route53_record" "cas_ui" {
  name            = var.hosted_zone_cas_ui.name
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_cas_ui.id

  alias {
    name                   = aws_lb.cas_ui.dns_name
    zone_id                = aws_lb.cas_ui.zone_id
    evaluate_target_health = true
  }
}

# /* Client requests will arrive at the CAS UI with a HOST header corresponding to
#    the public hostname of the CAS UI (which is CNAMEd through to the cas_ui
#    "A" record defined above). */
resource "aws_acm_certificate" "public_cas_ui" {
  domain_name       = var.cas_ui_public_fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  public_cas_ui_cert_validations = [
    for dvo in aws_acm_certificate.public_cas_ui.domain_validation_options : {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  ]
}

resource "aws_acm_certificate_validation" "public_cas_ui" {
  # Only attempt this stage if vars dictate so (see vars for explanation)
  count = var.cas_ui_public_cert_attempt_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.public_cas_ui.arn
  validation_record_fqdns = [for validation in local.public_cas_ui_cert_validations : validation.name]
}

# Redirect all port 80 requests to port 443
resource "aws_lb_listener" "cas_ui_http_redirect" {
  load_balancer_arn = aws_lb.cas_ui.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "cas_ui" {
  # Only attempt this stage if vars dictate so (see vars for explanation)
  count = var.cas_ui_public_cert_attempt_validation ? 1 : 0

  # Conditional logic required for the migration to CAS UI from Buyer UI - once this is complete in all environments, this can be refactored
  certificate_arn   = var.cas_ui_adopt_redirect_certificate == false ? aws_acm_certificate.public_cas_ui.arn : var.cas_ui_lb_listener_acm_arn
  load_balancer_arn = aws_lb.cas_ui.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.default_ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cas_ui.arn
  }
}

resource "aws_lb_listener_certificate" "cas_ui" {
  # Only attempt this stage if cas_ui_adopt_redirect_certificate == true
  count           = var.cas_ui_adopt_redirect_certificate == true ? 1 : 0
  certificate_arn = aws_acm_certificate.public_cas_ui.arn
  listener_arn    = aws_lb_listener.cas_ui[0].arn
}

# Paths we wish to exclude from outside access
resource "aws_lb_listener_rule" "blocked_frontend_paths_cas_ui" {
  # Only attempt this stage if vars dictate so (see vars for explanation)
  count = var.cas_ui_public_cert_attempt_validation ? 1 : 0

  listener_arn = aws_lb_listener.cas_ui[0].arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<p>Path not found. Sorry. Try <a href=\"https://${var.cas_ui_public_fqdn}/\">Home</a>.</p>"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = [
        "/health",
      ]
    }
  }
}

resource "aws_lb_target_group" "cas_ui" {
  # Requires an explicit depends_on
  depends_on = [
    aws_lb.cas_ui
  ]

  name            = "${var.resource_name_prefixes.hyphens}-TG-CASUI"
  ip_address_type = "ipv4"
  port            = "3000"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = var.vpc_id

  health_check {
    matcher  = "200"
    path     = "/health"
    port     = "3000"
    protocol = "HTTP"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }
}

locals {
  cas_ui_vcap_object = {
    redis = [
      {
        name        = var.cas_ui_replication_group_enabled == true ? "rediss" : "redis"
        credentials = local.redis_credentials
      }
    ]
  }
}

module "cas_ui_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    http = {
      cpu                   = var.task_container_configs.cas_ui.http_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = "curl -f http://localhost:3000/isAlive || exit 1"
      image                 = "${var.ecr_repo_url}:${var.docker_image_tags.cas_ui_http}"
      log_group_name        = "cas_ui"
      memory                = var.task_container_configs.cas_ui.http_memory
      mounts = [
      ]
      override_command             = null
      port                         = 3000
      secret_environment_variables = []
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "cas_ui"
  task_cpu               = var.task_container_configs.cas_ui.total_cpu
  task_memory            = var.task_container_configs.cas_ui.total_memory
}

resource "aws_ecs_service" "cas_ui" {
  cluster = var.ecs_cluster_arn

  desired_count          = 0 # Deploy manually
  enable_execute_command = var.enable_ecs_execute_command
  force_new_deployment   = false
  launch_type            = "FARGATE"
  name                   = "cas_ui"
  task_definition        = module.cas_ui_task.task_definition_arn

  dynamic "load_balancer" {
    for_each = var.cas_ui_public_cert_attempt_validation ? toset([1]) : toset([])
    content {
      container_name   = "http"
      container_port   = 3000
      target_group_arn = aws_lb_target_group.cas_ui.arn
    }
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.cas_ui_tasks.id,
      var.cat_api_clients_security_group_id,
      var.session_cache_clients_security_group_id,
    ]
    subnets = var.subnets.web.ids
  }

  lifecycle {
    # Don't kill scaled services every time we apply Terraform
    ignore_changes = [
      desired_count
    ]
  }
}

data "aws_iam_policy_document" "cas_ui_task__read_ssm_params" {
  version = "2012-10-17"

  statement {
    sid = "AllowCasUiParams"

    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/cas/ui/*"
    ]
  }
}

resource "aws_iam_policy" "cas_ui_task__read_ssm_params_policy" {
  name        = "cas_ui_read_ssm_params_policy"
  path        = "/"
  description = "cas ui task policy"
  policy      = data.aws_iam_policy_document.cas_ui_task__read_ssm_params.json
}

resource "aws_iam_role_policy_attachment" "cas_ui_task__read_ssm_params_policy_attach" {
  role       = module.cas_ui_task.task_role_name
  policy_arn = aws_iam_policy.cas_ui_task__read_ssm_params_policy.arn
}

resource "aws_iam_role_policy_attachment" "cas_ui_task__ecs_exec_access" {
  role       = module.cas_ui_task.task_role_name
  policy_arn = var.ecs_exec_policy_arn
}

resource "aws_security_group" "cas_ui_lb" {
  name        = "${var.resource_name_prefixes.normal}:LB:CASUI"
  description = "ALB for CAS UI"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:LB:CASUI"
  }
}

# To enable redirect from http
resource "aws_security_group_rule" "cas_ui_lb_http_in" {
  description = "Allow HTTP from approved addresses into the CAS UI LB"
  from_port   = 80
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.cas_ui_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_ui_lb.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "cas_ui_lb_https_in" {
  description = "Allow HTTPS from approved addresses into the CAS UI LB"
  from_port   = 443
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.cas_ui_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_ui_lb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "cas_ui_tasks" {
  name        = "${var.resource_name_prefixes.normal}:ECSTASK:CASUI"
  description = "Identifies the holder as one of the CAS UI tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:ECSTASK:CASUI"
  }
}

resource "aws_security_group_rule" "cas_ui_tasks__https_anywhere_out" {
  description = "Allows outward HTTPS from the cas_ui tasks to anywhere"

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_ui_tasks.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "cas_ui_lb__3000_cas_ui_tasks_out" {
  description = "Allow outward service traffic from the CAS UI LB to the cas_ui tasks"

  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_ui_lb.id
  source_security_group_id = aws_security_group.cas_ui_tasks.id
  to_port                  = 3000
  type                     = "egress"
}

resource "aws_security_group_rule" "cas_ui_tasks__lb_3000_in" {
  description = "Allow inward service traffic from the CAS UI LB to the cas_ui tasks"

  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_ui_tasks.id
  source_security_group_id = aws_security_group.cas_ui_lb.id
  to_port                  = 3000
  type                     = "ingress"
}
