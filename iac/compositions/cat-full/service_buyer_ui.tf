resource "aws_lb" "buyer_ui" {
  name               = "${var.resource_name_prefixes.hyphens}-ALB-BUYERUI"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.buyer_ui_lb.id]
  subnets            = module.vpc.subnets.public.ids
}

resource "aws_route53_record" "buyer_ui" {
  name            = local.fqdns.buyer_ui
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone.id

  alias {
    name                   = aws_lb.buyer_ui.dns_name
    zone_id                = aws_lb.buyer_ui.zone_id
    evaluate_target_health = true
  }
}

# Redirect all port 80 requests to port 443
resource "aws_lb_listener" "buyer_ui_http_redirect" {
  load_balancer_arn = aws_lb.buyer_ui.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "buyer_ui" {
  certificate_arn   = module.buyer_ui_cert.certificate_arn
  load_balancer_arn = aws_lb.buyer_ui.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.buyer_ui.arn
  }
}

# Paths we wish to exclude from outside access
resource "aws_lb_listener_rule" "blocked_frontend_paths" {
  listener_arn = aws_lb_listener.buyer_ui.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<p>Path not found. Sorry. Try <a href=\"https://${aws_route53_record.buyer_ui.fqdn}/\">Home</a>.</p>"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = [
        "/isAlive",
      ]
    }
  }
}

resource "aws_lb_target_group" "buyer_ui" {
  name            = "${var.resource_name_prefixes.hyphens}-TG-BUYERUI"
  ip_address_type = "ipv4"
  port            = "3000"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = module.vpc.vpc_id

  health_check {
    matcher  = "200"
    path     = "/isAlive"
    port     = "3000"
    protocol = "HTTP"
  }
}

locals {
  buyer_ui_vcap_object = {
    redis = [
      {
        name        = "redis"
        credentials = local.redis_credentials
      }
    ]
  }
}

module "buyer_ui_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    http = {
      cpu                   = var.task_container_configs.buyer_ui.http_cpu
      environment_variables = [
        { name = "AGREEMENTS_SERVICE_API_URL", value = var.buyer_ui_environment["agreements-service-api-url"] },
        { name = "AUTH_SERVER_BASE_URL", value = var.buyer_ui_environment["auth-server-base-url"] },
        { name = "AUTH_IDENTITY_BASE_URL", value = var.buyer_ui_environment["auth-identity-base-url"] },
        { name = "CAT_URL", value = "https://${aws_route53_record.buyer_ui.fqdn}" },
        { name = "CONCLAVE_WRAPPER_API_BASE_URL", value = var.buyer_ui_environment["conclave-wrapper-api-base-url"] },
        { name = "DASHBOARD_BANNER", value = var.buyer_ui_environment["dashboard-banner"] },
        { name = "GCLOUD_INDEX", value = var.buyer_ui_environment["gcloud-index"] },
        { name = "GCLOUD_SEARCH_API_URL", value = var.buyer_ui_environment["gcloud-search-api-url"] },
        { name = "GCLOUD_SERVICES_API_URL", value = var.buyer_ui_environment["gcloud-services-api-url"] },
        { name = "GCLOUD_SUPPLIER_API_URL", value = var.buyer_ui_environment["gcloud-supplier-api-url"] },
        { name = "GOOGLE_TAG_MANAGER_ID", value = var.buyer_ui_environment["google-tag-manager-id"] },
        { name = "GOOGLE_SITE_TAG_ID", value = var.buyer_ui_environment["google-site-tag-id"] },
        { name = "LOGIN_DIRECTOR_URL", value = var.buyer_ui_environment["login-director-url"] },
        { name = "LOGIT_ENVIRONMENT", value = var.buyer_ui_environment["logit-environment"] },
        { name = "NODE_ENV", value = var.buyer_ui_environment["node-env"] },
        { name = "PORT", value = "3000" },
        { name = "ROLLBAR_HOST", value = var.buyer_ui_environment["rollbar-host"] },
        # Setting SESSIONS_MODE differently will necessitate in-transit encryption for Redis
        { name = "SESSIONS_MODE", value = "aws-native" },
        { name = "TENDERS_SERVICE_API_URL", value = "https://${aws_route53_record.cat_api.fqdn}" },
        { name = "VCAP_SERVICES", value = jsonencode(local.buyer_ui_vcap_object) },
      ]
      essential                    = true
      healthcheck_command          = "curl -f http://localhost:3000/isAlive || exit 1"
      image                        = "${module.ecr_repos.repository_urls["buyer-ui"]}:${var.docker_image_tags.buyer_ui_http}"
      log_group_name               = "${var.environment_name}-buyer-ui-nginx" # Must exist already
      memory                       = var.task_container_configs.buyer_ui.http_memory
      mounts                       = []
      override_command             = null
      port                         = 3000
      secret_environment_variables = [
        { name = "AUTH_SERVER_CLIENT_ID", valueFrom = var.buyer_ui_ssm_secret_paths["auth-server-client-id"] },
        { name = "AUTH_SERVER_CLIENT_SECRET", valueFrom = var.buyer_ui_ssm_secret_paths["auth-server-client-secret"] },
        { name = "CONCLAVE_WRAPPER_API_KEY", valueFrom = var.buyer_ui_ssm_secret_paths["conclave-wrapper-api-key"] },
        { name = "GCLOUD_SEARCH_API_TOKEN", valueFrom = var.buyer_ui_ssm_secret_paths["gcloud-search-api-token"] },
        { name = "GCLOUD_TOKEN", valueFrom = var.buyer_ui_ssm_secret_paths["gcloud-token"] },
        { name = "LOGIT_API_KEY", valueFrom = var.buyer_ui_ssm_secret_paths["logit-api-key"] },
        { name = "ROLLBAR_ACCESS_TOKEN", valueFrom = var.buyer_ui_ssm_secret_paths["rollbar-access-token"] },
        { name = "SESSION_SECRET", valueFrom = aws_ssm_parameter.session_secret.arn },
      ]
    }
  }
  ecs_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  family_name            = "buyer_ui"
  task_cpu               = var.task_container_configs.buyer_ui.total_cpu
  task_memory            = var.task_container_configs.buyer_ui.total_memory
}

resource "aws_ecs_service" "buyer_ui" {
  cluster              = module.ecs_cluster.cluster_arn
  desired_count        = 0 # Deploy manually
  force_new_deployment = false
  launch_type          = "FARGATE"
  name                 = "buyer_ui"
  task_definition      = module.buyer_ui_task.task_definition_arn

  load_balancer {
    container_name   = "http"
    container_port   = 3000
    target_group_arn = aws_lb_target_group.buyer_ui.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [
      aws_security_group.buyer_ui_tasks.id,
      aws_security_group.cat_api_clients.id,
      module.session_cache.clients_security_group_id,
    ]
    subnets = module.vpc.subnets.web.ids
  }

  lifecycle {
    # Don't kill scaled services every time we apply Terraform
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_security_group" "buyer_ui_lb" {
  name        = "${var.resource_name_prefixes.normal}:LB:BUYERUI"
  description = "ALB for Buyer UI"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:LB:BUYERUI"
  }
}

# To enable redirect from http
resource "aws_security_group_rule" "buyer_ui_lb_http_in" {
  description     = "Allow HTTP from approved addresses into the Buyer UI LB"
  from_port       = 80
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.buyer_ui_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.buyer_ui_lb.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "buyer_ui_lb_https_in" {
  description     = "Allow HTTPS from approved addresses into the Buyer UI LB"
  from_port       = 443
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.buyer_ui_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.buyer_ui_lb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "buyer_ui_tasks" {
  name        = "${var.resource_name_prefixes.normal}:ECSTASK:BUYERUI"
  description = "Identifies the holder as one of the Buyer UI tasks"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:ECSTASK:BUYERUI"
  }
}

resource "aws_security_group_rule" "buyer_ui_tasks__https_anywhere_out" {
  description = "Allows outward HTTPS from the Buyer_ui tasks to anywhere"

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.buyer_ui_tasks.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "buyer_ui_lb__3000_buyer_ui_tasks_out" {
  description = "Allow outward service traffic from the Buyer UI LB to the Buyer_ui tasks"

  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.buyer_ui_lb.id
  source_security_group_id = aws_security_group.buyer_ui_tasks.id
  to_port                  = 3000
  type                     = "egress"
}

resource "aws_security_group_rule" "buyer_ui_tasks__lb_3000_in" {
  description = "Allow inward service traffic from the Buyer UI LB to the Buyer_ui tasks"

  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.buyer_ui_tasks.id
  source_security_group_id = aws_security_group.buyer_ui_lb.id
  to_port                  = 3000
  type                     = "ingress"
}
