locals {
  cat_api_vcap_object = {
    #VCAP_SERVICES={"aws-s3-bucket": [{"aws_region": "..."}], "opensearch": [{"hostname": "abc", "username": "def", "password": "ghi", "port": "1234"}]}
    opensearch = [
      {
        "hostname" = module.search_domain.opensearch_endpoint,
      }
    ]
  }
}

resource "aws_lb" "cat_api" {
  name               = "${var.resource_name_prefixes.hyphens}-ALB-CATAPI"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.cat_api_lb.id
  ]
  subnets = module.vpc.subnets.public.ids
}

resource "aws_route53_record" "cat_api" {
  name            = local.fqdns.cat_api
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone.id
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
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cat_api.arn
  }
}

resource "aws_lb_target_group" "cat_api" {
  name            = "${var.resource_name_prefixes.hyphens}-TG-CATAPI"
  ip_address_type = "ipv4"
  port            = "8080"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = module.vpc.vpc_id

  health_check {
    matcher  = "200"
    path     = "/health"
    port     = "8080"
    protocol = "HTTP"
  }
}

module "cat_api_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    cat = {
      cpu = var.task_container_configs.cat_api.http_cpu
      environment_variables = [
        { name = "CONFIG_EXTERNAL_AGREEMENTSSERVICE_BASEURL", value = data.aws_ssm_parameter.parameter["agreements-service-base-url"].value },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_BASEURL", value = data.aws_ssm_parameter.parameter["conclave-wrapper-api-base-url"].value },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESBASEURL", value = data.aws_ssm_parameter.parameter["conclave-wrapper-identities-api-base-url"].value },
        # Skipping CONFIG_EXTERNAL_DOCUPLOADSVC_AWSACCESSKEYID and CONFIG_EXTERNAL_DOCUPLOADSVC_AWSSECRETKEY
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_GETBASEURL", value = data.aws_ssm_parameter.parameter["document-upload-service-get-base-url"].value },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_S3BUCKET", value = data.aws_ssm_parameter.parameter["document-upload-service-s3-bucket"].value },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_UPLOADBASEURL", value = data.aws_ssm_parameter.parameter["document-upload-service-upload-base-url"].value },
        { name = "CONFIG_EXTERNAL_JAGGAER_BASEURL", value = data.aws_ssm_parameter.parameter["jaggaer-base-url"].value },
        { name = "CONFIG_EXTERNAL_JAGGAER_CREATEPROJECT_TEMPLATEID", value = data.aws_ssm_parameter.parameter["jaggaer-project-template-id"].value },
        { name = "CONFIG_EXTERNAL_JAGGAER_CREATERFX_TEMPLATEID", value = data.aws_ssm_parameter.parameter["jaggaer-itt-template-id"].value },
        { name = "CONFIG_EXTERNAL_JAGGAER_SELFSERVICEID", value = data.aws_ssm_parameter.parameter["jaggaer-self-service-id"].value },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_INVALIDDUNSTEMPLATEID", value = data.aws_ssm_parameter.parameter["gov-uk-notify_invalid-duns-template-id"].value },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TARGETEMAIL", value = data.aws_ssm_parameter.parameter["gov-uk-notify_target-email"].value },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TEMPLATEID", value = data.aws_ssm_parameter.parameter["gov-uk-notify_template-id"].value },
        { name = "CONFIG_EXTERNAL_PROJECTS_SYNC_SCHEDULE", value = data.aws_ssm_parameter.parameter["projects-to-opensearch-sync-schedule"].value },
        { name = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_SCHEDULE", value = data.aws_ssm_parameter.parameter["oppertunities-s3-export-schedule"].value },
        { name = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_UI_LINK", value = data.aws_ssm_parameter.parameter["oppertunities-s3-export-ui-link"].value },
        { name = "CONFIG_FLAGS_DEVMODE", value = var.cat_api_settings.dev_mode },
        { name = "CONFIG_FLAGS_RESOLVEBUYERUSERSBYSSO", value = var.cat_api_settings.resolve_buyer_users_by_sso },
        { name = "CONFIG_ROLLBAR_ENVIRONMENT", value = data.aws_ssm_parameter.parameter["rollbar-environment"].value },
        { name = "ENDPOINT_EXECUTIONTIME_ENABLED", value = var.cat_api_settings.eetime_enabled },
        { name = "LOGGING_LEVEL_UK_GOV_CROWNCOMMERCIAL_DTS_SCALE_CAT", value = var.cat_api_settings.log_level },
        { name = "SPRING_PROFILES_ACTIVE", value = "cloud" },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_JAGGAER_TOKENURI", value = data.aws_ssm_parameter.parameter["jaggaer-token-url"].value },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTID", value = data.aws_ssm_parameter.parameter["jaggaer-client-id"].value },
        { name = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI", value = data.aws_ssm_parameter.parameter["auth-server-jwk-set-uri"].value },
        { name = "VCAP_SERVICES", value = jsonencode(local.cat_api_vcap_object) },
      ]
      essential           = true
      healthcheck_command = "curl -f http://localhost:8080/health || exit 1"
      image               = "${module.ecr_repos.repository_urls["cat-api"]}:${var.docker_image_tags.cat_api_http}"
      // TODO: log groups
      //      log_group_name      = module.logs.log_group_name
      memory           = var.task_container_configs.cat_api.http_memory
      mounts           = []
      override_command = null
      port             = 8080
      secret_environment_variables = [
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_APIKEY", valueFrom = local.ssm_secret_parameters["conclave-wrapper-api-key"] },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESAPIKEY", valueFrom = local.ssm_secret_parameters["conclave-wrapper-identities-api-key"] },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_APIKEY", valueFrom = local.ssm_secret_parameters["document-upload-service-api-key"] },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_APIKEY", valueFrom = local.ssm_secret_parameters["gov-uk-notify_api-key"] },
        { name = "CONFIG_ROLLBAR_ACCESSTOKEN", valueFrom = local.ssm_secret_parameters["rollbar-access-token"] },
        // might need to be prefixed with jdbc: to work?
        { name = "SPRING_DATASOURCE_URL", valueFrom = module.db.postgres_connection_url_ssm_parameter_arn },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTSECRET", valueFrom = local.ssm_secret_parameters["jaggaer-client-secret"] },
      ]
    }
  }
  ecs_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  family_name            = "cat_api"
  task_cpu               = var.task_container_configs.cat_api.total_cpu
  task_memory            = var.task_container_configs.cat_api.total_memory
}

resource "aws_ecs_service" "cat_api" {
  cluster              = module.ecs_cluster.cluster_arn
  desired_count        = 0 # Deploy manually
  force_new_deployment = false
  launch_type          = "FARGATE"
  name                 = "cat_api"
  task_definition      = module.cat_api_task.task_definition_arn

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

