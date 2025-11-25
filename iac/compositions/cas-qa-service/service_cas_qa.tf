locals {
  redis_credentials = {
    host     = var.redis_credentials.host,
    password = var.redis_credentials.password,
    port     = var.redis_credentials.port,
  }
}

resource "aws_lb" "cas_qa" {
  name               = "${var.resource_name_prefixes.hyphens}-ALB-CASQA"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cas_qa_lb.id]
  subnets            = var.subnets.web.ids

  drop_invalid_header_fields = var.drop_invalid_header_fields

  enable_deletion_protection = var.lb_enable_deletion_protection

  # access_logs {
  #   bucket  = var.logs_bucket_id
  #   prefix  = "access-logs/casqa"
  #   enabled = var.enable_lb_access_logs
  # }

  # connection_logs {
  #   bucket  = var.logs_bucket_id
  #   prefix  = "connection-logs/casqa"
  #   enabled = var.enable_lb_connection_logs
  # }

  tags = {
    WAF_ENABLED = var.cas_qa_lb_waf_enabled == true ? true : null
  }
}

resource "aws_route53_record" "cas_qa" {
  name            = var.hosted_zone_cas_qa.name
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_cas_qa.id

  alias {
    name                   = aws_lb.cas_qa.dns_name
    zone_id                = aws_lb.cas_qa.zone_id
    evaluate_target_health = true
  }
}

# resource "aws_acm_certificate" "public_cas_qa" {
#   domain_name       = var.cas_qa_public_fqdn
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# locals {
#   public_cas_qa_cert_validations = [
#     for dvo in aws_acm_certificate.public_cas_qa.domain_validation_options : {
#       name  = dvo.resource_record_name
#       value = dvo.resource_record_value
#       type  = dvo.resource_record_type
#     }
#   ]
# }

# resource "aws_acm_certificate_validation" "public_cas_qa" {
#   certificate_arn         = aws_acm_certificate.public_cas_qa.arn
#   validation_record_fqdns = [for validation in local.public_cas_qa_cert_validations : validation.name]
# }

# Redirect all port 80 requests to port 443
resource "aws_lb_listener" "cas_qa_http" {
  load_balancer_arn = aws_lb.cas_qa.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.cas_qa.arn
      }
    }

    # redirect {
    #   port        = "443"
    #   protocol    = "HTTPS"
    #   status_code = "HTTP_301"
    # }
  }
}

# resource "aws_lb_listener" "cas_qa" {
#   certificate_arn   = aws_acm_certificate.public_cas_qa.arn
#   load_balancer_arn = aws_lb.cas_qa.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = var.default_ssl_policy

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.cas_qa.arn
#   }
# }

# resource "aws_lb_listener_rule" "blocked_frontend_paths_cas_qa" {

#   listener_arn = aws_lb_listener.cas_qa.arn

#   action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/html"
#       message_body = "<p>Path not found. Sorry. Try <a href=\"https://${var.cas_qa_public_fqdn}/\">Home</a>.</p>"
#       status_code  = "404"
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/health",
#       ]
#     }
#   }
# }

resource "aws_lb_target_group" "cas_qa" {
  # Requires an explicit depends_on
  depends_on = [
    aws_lb.cas_qa
  ]

  name            = "${var.resource_name_prefixes.hyphens}-TG-CASQA"
  ip_address_type = "ipv4"
  port            = "4000"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = var.vpc_id

  health_check {
    matcher  = "200"
    path     = "/health"
    port     = "4000"
    protocol = "HTTP"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }
}

module "cas_qa_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    http = {
      cpu                   = var.task_container_configs.cas_qa.http_cpu
      environment_variables = []
      essential             = true
      healthcheck_command   = "curl -f http://localhost:4000/isAlive || exit 1"
      image                 = "${var.ecr_repo_url}:${var.docker_image_tags.cas_qa_http}"
      log_group_name        = "cas_qa"
      memory                = var.task_container_configs.cas_qa.http_memory
      mounts = [
      ]
      override_command             = null
      port                         = 4000
      secret_environment_variables = []
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role.arn
  family_name            = "cas_qa"
  task_cpu               = var.task_container_configs.cas_qa.total_cpu
  task_memory            = var.task_container_configs.cas_qa.total_memory
}

resource "aws_ecs_service" "cas_qa" {
  cluster = var.ecs_cluster_arn

  desired_count          = 0 # Deploy manually
  enable_execute_command = var.enable_ecs_execute_command
  force_new_deployment   = false
  launch_type            = "FARGATE"
  name                   = "cas_qa"
  task_definition        = module.cas_qa_task.task_definition_arn

  load_balancer {
    target_group_arn = aws_lb_target_group.cas_qa.arn
    container_name   = "http"
    container_port   = 4000
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.cas_qa_tasks.id,
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

data "aws_iam_policy_document" "cas_qa_task_read_ssm_params" {
  version = "2012-10-17"

  statement {
    sid = "AllowCasQaParams"

    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/qanda/api/*"
    ]
  }
}

resource "aws_iam_policy" "cas_qa_task_read_ssm_params_policy" {
  name        = "cas_qa_read_ssm_params_policy"
  path        = "/"
  description = "cas qa task policy"
  policy      = data.aws_iam_policy_document.cas_qa_task_read_ssm_params.json
}

resource "aws_iam_role_policy_attachment" "cas_qa_task_read_ssm_params_policy_attach" {
  role       = module.cas_qa_task.task_role_name
  policy_arn = aws_iam_policy.cas_qa_task_read_ssm_params_policy.arn
}

resource "aws_iam_role_policy_attachment" "cas_qa_task_ecs_exec_access" {
  role       = module.cas_qa_task.task_role_name
  policy_arn = var.ecs_exec_policy_arn
}

resource "aws_security_group" "cas_qa_lb" {
  name        = "${var.resource_name_prefixes.normal}:LB:CASQA"
  description = "ALB for CAS QA"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:LB:CASQA"
  }
}

# To enable redirect from http
resource "aws_security_group_rule" "cas_qa_lb_http_in" {
  description = "Allow HTTP from approved addresses into the CAS QA LB"
  from_port   = 80
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.cas_qa_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_qa_lb.id
  to_port           = 80
  type              = "ingress"
}

# resource "aws_security_group_rule" "cas_qa_lb_https_in" {
#   description = "Allow HTTPS from approved addresses into the CAS QA LB"
#   from_port   = 443
#   prefix_list_ids = [
#     aws_ec2_managed_prefix_list.cas_qa_ingress_safelist.id
#   ]
#   protocol          = "tcp"
#   security_group_id = aws_security_group.cas_qa_lb.id
#   to_port           = 443
#   type              = "ingress"
# }

resource "aws_security_group" "cas_qa_tasks" {
  name        = "${var.resource_name_prefixes.normal}:ECSTASK:CASQA"
  description = "Identifies the holder as one of the CAS QA tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:ECSTASK:CASQA"
  }
}

resource "aws_security_group_rule" "cas_qa_tasks_http_anywhere_out" {
  description = "Allows outward HTTP from the cas_qa tasks to anywhere"

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_qa_tasks.id
  to_port           = 80
  type              = "egress"
}

resource "aws_security_group_rule" "cas_qa_lb_4000_cas_qa_tasks_out" {
  description = "Allow outward service traffic from the CAS QA LB to the cas_qa tasks"

  from_port                = 4000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_qa_lb.id
  source_security_group_id = aws_security_group.cas_qa_tasks.id
  to_port                  = 4000
  type                     = "egress"
}

resource "aws_security_group_rule" "cas_qa_tasks_lb_4000_in" {
  description = "Allow inward service traffic from the CAS QA LB to the cas_qa tasks"

  from_port                = 4000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_qa_tasks.id
  source_security_group_id = aws_security_group.cas_qa_lb.id
  to_port                  = 4000
  type                     = "ingress"
}