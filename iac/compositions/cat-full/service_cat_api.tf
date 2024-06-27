locals {
  cat_api_spring_datasource_url = format("jdbc:postgresql://%s:%d/%s", module.db.db_connection_host, module.db.db_connection_port, module.db.db_connection_name)

  cat_api_vcap_object = {
    aws-s3-bucket = [
      {
        credentials = {
          aws_region  = var.aws_region,
          bucket_name = local.documents_bucket_name,
        },
        name = "aws-ccs-scale-cat-tenders-s3-documents", # Naming convention matters to the code
      }
    ],
    opensearch = [
      {
        credentials = {
          hostname = module.search_domain.opensearch_endpoint,
          port     = "443",
          # Assumes there has been no customisation/change in the core module that owns module.search_domain
        },
        name = "aws-ccs-scale-cat-opensearch", # Naming convention matters to the code
      }
    ],
  }
}

resource "aws_lb" "cat_api" {
  name               = "${var.resource_name_prefixes.hyphens}-ALB-CATAPI"
  idle_timeout       = var.cat_api_idle_timeout
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.cat_api_lb.id
  ]
  subnets = module.vpc.subnets.public.ids

  drop_invalid_header_fields = var.drop_invalid_header_fields

  enable_deletion_protection = var.lb_enable_deletion_protection

  access_logs {
    bucket  = module.logs_bucket.bucket_id
    prefix  = "access-logs/catapi"
    enabled = var.enable_lb_access_logs
  }

  connection_logs {
    bucket  = module.logs_bucket.bucket_id
    prefix  = "connection-logs/catapi"
    enabled = var.enable_lb_connection_logs
  }

  tags = {
    WAF_ENABLED = var.cas_cat_api_lb_waf_enabled != false ? true : null
  }
}

resource "aws_route53_record" "cat_api" {
  name            = var.hosted_zone_api.name
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_api.id
  alias {
    name                   = aws_lb.cat_api.dns_name
    zone_id                = aws_lb.cat_api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "cat_api" {
  certificate_arn   = module.cat_api_cert.certificate_arn
  load_balancer_arn = aws_lb.cat_api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.default_ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cat_api.arn
  }
}

resource "aws_lb_listener_rule" "cat_api_blocked_frontend_paths" {
  listener_arn = aws_lb_listener.cat_api.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = "403"
    }
  }

  condition {
    path_pattern {
      values = [
        "/actuator/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "cat_api" {
  # Requires an explicit depends_on
  depends_on = [
    aws_lb.cat_api
  ]

  name            = "${var.resource_name_prefixes.hyphens}-TG-CATAPI"
  ip_address_type = "ipv4"
  port            = "8080"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = module.vpc.vpc_id

  health_check {
    matcher  = "200"
    path     = "/actuator/health"
    port     = "8080"
    protocol = "HTTP"
  }
}

module "cat_api_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    http = {
      cpu = var.task_container_configs.cat_api.http_cpu
      environment_variables = [
        { name = "CONFIG_FLAGS_DEVMODE", value = var.cat_api_config_flags_devmode },
        {
          name = "CONFIG_FLAGS_RESOLVEBUYERUSERSBYSSO",
          # Assuming that Spring uses Java Boolean class to convert these
          value = var.cat_api_resolve_buyer_users_by_sso
        },
        { name = "ENDPOINT_EXECUTIONTIME_ENABLED", value = var.cat_api_eetime_enabled },
        { name = "JBP_CONFIG_SPRING_AUTO_RECONFIGURATION", value = "{enabled: false}" }, # Mirror existing
        {
          name  = "LOGGING_LEVEL_UK_GOV_CROWNCOMMERCIAL_DTS_SCALE_CAT",
          value = var.cat_api_log_level
        },
        { name = "MANAGEMENT_CLOUDFOUNDRY_ENABLED", value = "false" },
        { name = "SPRING_DATASOURCE_URL", value = local.cat_api_spring_datasource_url },
        { name = "SPRING_DATASOURCE_USERNAME", value = module.db.db_connection_username },
        { name = "SPRING_PROFILES_ACTIVE", value = "cloud" },
        { name = "VCAP_SERVICES", value = jsonencode(local.cat_api_vcap_object) },
      ]
      essential           = true
      healthcheck_command = "curl -sf http://localhost:8080/actuator/health || exit 1"
      image               = "${module.ecr_repos.repository_urls["cat-api"]}:${var.docker_image_tags.cat_api_http}"
      log_group_name      = "cat_api"
      memory              = var.task_container_configs.cat_api.http_memory
      mounts              = []
      override_command    = null
      port                = 8080
      secret_environment_variables = [
        {
          name      = "CONFIG_EXTERNAL_AGREEMENTSSERVICE_APIKEY",
          valueFrom = aws_ssm_parameter.manual_config["agreements-service-api-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_AGREEMENTSSERVICE_BASEURL",
          valueFrom = aws_ssm_parameter.manual_config["agreements-service-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_APIKEY",
          valueFrom = aws_ssm_parameter.manual_config["conclave-wrapper-api-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_BASEURL",
          valueFrom = aws_ssm_parameter.manual_config["conclave-wrapper-api-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESAPIKEY",
          valueFrom = aws_ssm_parameter.manual_config["conclave-wrapper-identities-api-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESBASEURL",
          valueFrom = aws_ssm_parameter.manual_config["conclave-wrapper-identities-api-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_APIKEY",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-api-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_AWSACCESSKEYID",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-aws-access-key-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_AWSSECRETKEY",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-aws-secret-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_GETBASEURL",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-get-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_S3BUCKET",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-s3-bucket"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_DOCUPLOADSVC_UPLOADBASEURL",
          valueFrom = aws_ssm_parameter.manual_config["document-upload-service-upload-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_BASEURL",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-base-url"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_BUSINESSUNITNAME",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-business-unit-name"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_CREATEPROJECTTEMPLATEID",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-project-template-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_CREATERFXTEMPLATEID",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-itt-template-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_ENABLECONTRACTPLUS",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-enable-contract-plus"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_JAGGAER_SELFSERVICEID",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-self-service-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_NOTIFICATION_APIKEY",
          valueFrom = aws_ssm_parameter.manual_config["gov-uk-notify-api-key"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_INVALIDDUNSTEMPLATEID",
          valueFrom = aws_ssm_parameter.manual_config["gov-uk-notify-invalid-duns-template-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TARGETEMAIL",
          valueFrom = aws_ssm_parameter.manual_config["gov-uk-notify-target-email"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TEMPLATEID",
          valueFrom = aws_ssm_parameter.manual_config["gov-uk-notify-template-id"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_PROJECTS_SYNC_SCHEDULE",
          valueFrom = aws_ssm_parameter.manual_config["projects-to-opensearch-sync-schedule"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_SCHEDULE",
          valueFrom = aws_ssm_parameter.manual_config["oppertunities-s3-export-schedule"].arn
        },
        {
          name      = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_UI_LINK",
          valueFrom = aws_ssm_parameter.manual_config["oppertunities-s3-export-ui-link"].arn
        },
        {
          name      = "CONFIG_ROLLBAR_ACCESSTOKEN",
          valueFrom = aws_ssm_parameter.manual_config["rollbar-access-token"].arn
        },
        { name = "CONFIG_ROLLBAR_ENVIRONMENT", valueFrom = aws_ssm_parameter.manual_config["rollbar-environment"].arn },
        { name = "SPRING_DATASOURCE_PASSWORD", valueFrom = module.db.postgres_connection_password_ssm_parameter_arn },
        {
          name      = "SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_JAGGAER_TOKENURI",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-token-url"].arn
        },
        {
          name      = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTID",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-client-id"].arn
        },
        {
          name      = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTSECRET",
          valueFrom = aws_ssm_parameter.manual_config["jaggaer-client-secret"].arn
        },
        {
          name      = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI",
          valueFrom = aws_ssm_parameter.manual_config["auth-server-jwk-set-uri"].arn
        },


      ]
    }
  }
  ecs_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  family_name            = "cat_api"
  task_cpu               = var.task_container_configs.cat_api.total_cpu
  task_memory            = var.task_container_configs.cat_api.total_memory
}

resource "aws_iam_role_policy_attachment" "cat_api__documents_bucket_full_access" {
  role       = module.cat_api_task.task_role_name
  policy_arn = aws_iam_policy.documents_bucket_full_access.arn
}

resource "aws_ecs_service" "cat_api" {
  cluster                = module.ecs_cluster.cluster_arn
  desired_count          = 0 # Deploy manually
  enable_execute_command = var.enable_ecs_execute_command
  force_new_deployment   = false
  launch_type            = "FARGATE"
  name                   = "cat_api"
  task_definition        = module.cat_api_task.task_definition_arn

  load_balancer {
    container_name   = "http"
    container_port   = 8080
    target_group_arn = aws_lb_target_group.cat_api.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.cat_api_tasks.id,
      module.db.db_clients_security_group_id,
      module.search_domain.opensearch_clients_security_group_id
    ]
    subnets = module.vpc.subnets.application.ids
  }

  lifecycle {
    # Don't kill scaled services every time we apply Terraform
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_iam_role_policy_attachment" "cat_api_task__ecs_exec_access" {
  role       = module.cat_api_task.task_role_name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_security_group" "cat_api_lb" {
  name        = "${var.resource_name_prefixes.normal}:LB:CATAPI"
  description = "ALB for CAT API"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:LB:CATAPI"
  }
}

resource "aws_security_group_rule" "cat_api_lb__public_https_in" {
  description = "Allow HTTPS from approved addresses into the CAT API LB"
  from_port   = 443
  prefix_list_ids = [
    aws_ec2_managed_prefix_list.cat_api_ingress_safelist.id
  ]
  protocol          = "tcp"
  security_group_id = aws_security_group.cat_api_lb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "cat_api_tasks" {
  name        = "${var.resource_name_prefixes.normal}:ECSTASK:CATAPI"
  description = "Identifies the holder as one of the CAT API tasks"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:ECSTASK:CATAPI"
  }
}

resource "aws_security_group_rule" "cat_api_tasks__https_anywhere" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cat_api_tasks.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "cat_api_lb__8080_tasks_out" {
  description = "Allow outward service traffic from the CAT API LB to the tasks"

  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cat_api_lb.id
  source_security_group_id = aws_security_group.cat_api_tasks.id
  to_port                  = 8080
  type                     = "egress"
}

resource "aws_security_group_rule" "cat_api_tasks__lb_8080_in" {
  description = "Allow inward service traffic from the CAT API LB to the tasks"

  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cat_api_tasks.id
  source_security_group_id = aws_security_group.cat_api_lb.id
  to_port                  = 8080
  type                     = "ingress"
}

resource "aws_security_group" "cat_api_clients" {
  name        = "${var.resource_name_prefixes.normal}:CATAPICLIENT"
  description = "Identifies the holder as being permitted to access the CAT API LB internally from the VPC"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:CATAPICLIENT"
  }
}

resource "aws_security_group_rule" "cat_api_clients__cat_api_lb_https_out" {
  description              = "Allow HTTPS out of the CAT API clients to the CAT API LB"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cat_api_clients.id
  source_security_group_id = aws_security_group.cat_api_lb.id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "cat_api_lb__cat_api_clients_https_in" {
  description              = "Allow inward HTTPS traffic from the CAT API clients to the CAT API LB"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cat_api_lb.id
  source_security_group_id = aws_security_group.cat_api_clients.id
  to_port                  = 443
  type                     = "ingress"
}

# autoscaling

resource "aws_appautoscaling_target" "api_autoscale_target" {
  max_capacity       = var.api_autoscale_instance_max_count
  min_capacity       = var.api_autoscale_instance_min_count
  resource_id        = "service/${var.resource_name_prefixes.hyphens}-CAS/cat_api"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_autoscale_policy" {
  name               = "api_autoscale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api_autoscale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_autoscale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api_autoscale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = var.api_autoscale_scale_in_cooldown
    scale_out_cooldown = var.api_autoscale_scale_out_cooldown
    target_value       = var.api_autoscale_target_cpu
  }
  #depends_on = [aws_appautoscaling_target.api_autoscale_target]
}
