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
          port     = "443", # Assumes there has been no customisation/change in the core module that owns module.search_domain
        },
        name = "aws-ccs-scale-cat-opensearch", # Naming convention matters to the code
      }
    ],
  }

  document_upload_service_bucket_arn = format("arn:aws:s3:::%s", var.cat_api_environment["document-upload-service-s3-bucket"])
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
  ssl_policy        = "ELBSecurityPolicy-2016-08"

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
        { name = "CONFIG_EXTERNAL_AGREEMENTSSERVICE_BASEURL", value = var.cat_api_environment["agreements-service-base-url"] },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_BASEURL", value = var.cat_api_environment["conclave-wrapper-api-base-url"] },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESBASEURL", value = var.cat_api_environment["conclave-wrapper-identities-api-base-url"] },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_GETBASEURL", value = var.cat_api_environment["document-upload-service-get-base-url"] },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_S3BUCKET", value = var.cat_api_environment["document-upload-service-s3-bucket"] },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_UPLOADBASEURL", value = var.cat_api_environment["document-upload-service-upload-base-url"] },
        { name = "CONFIG_EXTERNAL_JAGGAER_BASEURL", value = var.cat_api_environment["jaggaer-base-url"] },
        { name = "CONFIG_EXTERNAL_JAGGAER_CREATEPROJECT_TEMPLATEID", value = var.cat_api_environment["jaggaer-project-template-id"] },
        { name = "CONFIG_EXTERNAL_JAGGAER_CREATERFX_TEMPLATEID", value = var.cat_api_environment["jaggaer-itt-template-id"] },
        { name = "CONFIG_EXTERNAL_JAGGAER_SELFSERVICEID", value = var.cat_api_environment["jaggaer-self-service-id"] },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_INVALIDDUNSTEMPLATEID", value = var.cat_api_environment["gov-uk-notify_invalid-duns-template-id"] },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TARGETEMAIL", value = var.cat_api_environment["gov-uk-notify_target-email"] },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_USERREGISTRATION_TEMPLATEID", value = var.cat_api_environment["gov-uk-notify_template-id"] },
        { name = "CONFIG_EXTERNAL_PROJECTS_SYNC_SCHEDULE", value = var.cat_api_environment["projects-to-opensearch-sync-schedule"] },
        { name = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_SCHEDULE", value = var.cat_api_environment["oppertunities-s3-export-schedule"] },
        { name = "CONFIG_EXTERNAL_S3_OPPERTUNITIES_UI_LINK", value = var.cat_api_environment["oppertunities-s3-export-ui-link"] },
        { name = "CONFIG_FLAGS_DEVMODE", value = tostring(var.cat_api_environment["dev_mode"]) },
        { name = "CONFIG_FLAGS_RESOLVEBUYERUSERSBYSSO", value = tostring(var.cat_api_environment["resolve_buyer_users_by_sso"]) },
        { name = "CONFIG_ROLLBAR_ENVIRONMENT", value = var.cat_api_environment["rollbar-environment"] },
        { name = "ENDPOINT_EXECUTIONTIME_ENABLED", value = tostring(var.cat_api_environment["eetime_enabled"]) },
        { name = "JBP_CONFIG_SPRING_AUTO_RECONFIGURATION", value = "{enabled: false}" }, # Mirror existing
        { name = "LOGGING_LEVEL_UK_GOV_CROWNCOMMERCIAL_DTS_SCALE_CAT", value = var.cat_api_environment["log_level"] },
        { name = "MANAGEMENT_CLOUDFOUNDRY_ENABLED", value = "false" },
        { name = "SPRING_DATASOURCE_URL", value = local.cat_api_spring_datasource_url },
        { name = "SPRING_DATASOURCE_USERNAME", value = module.db.db_connection_username },
        { name = "SPRING_PROFILES_ACTIVE", value = "cloud" },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_JAGGAER_TOKENURI", value = var.cat_api_environment["jaggaer-token-url"] },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTID", value = var.cat_api_environment["jaggaer-client-id"] },
        { name = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI", value = var.cat_api_environment["auth-server-jwk-set-uri"] },
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
        { name = "CONFIG_EXTERNAL_AGREEMENTSSERVICE_APIKEY", valueFrom = var.cat_api_ssm_secret_paths["agreements-service-api-key"] },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_APIKEY", valueFrom = var.cat_api_ssm_secret_paths["conclave-wrapper-api-key"] },
        { name = "CONFIG_EXTERNAL_CONCLAVEWRAPPER_IDENTITIESAPIKEY", valueFrom = var.cat_api_ssm_secret_paths["conclave-wrapper-identities-api-key"] },
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_AWSACCESSKEYID", valueFrom = var.cat_api_ssm_secret_paths["document-upload-service-aws-access-key-id"] }, # TODO: Use IAM role permissions
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_AWSSECRETKEY", valueFrom = var.cat_api_ssm_secret_paths["document-upload-service-aws-secret-key"] },      # TODO: Use IAM role permissions
        { name = "CONFIG_EXTERNAL_DOCUPLOADSVC_APIKEY", valueFrom = var.cat_api_ssm_secret_paths["document-upload-service-api-key"] },
        { name = "CONFIG_EXTERNAL_NOTIFICATION_APIKEY", valueFrom = var.cat_api_ssm_secret_paths["gov-uk-notify_api-key"] },
        { name = "CONFIG_ROLLBAR_ACCESSTOKEN", valueFrom = var.cat_api_ssm_secret_paths["rollbar-access-token"] },
        { name = "SPRING_DATASOURCE_PASSWORD", valueFrom = module.db.postgres_connection_password_ssm_parameter_arn },
        { name = "SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_JAGGAER_CLIENTSECRET", valueFrom = var.cat_api_ssm_secret_paths["jaggaer-client-secret"] },
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

data "aws_iam_policy_document" "document_upload_service_bucket_read_access" {
  statement {
    sid     = "AllowDocumentUploadBucketRead"
    actions = ["s3:GetObject"]
    effect  = "Allow"

    resources = [local.document_upload_service_bucket_arn]
  }
}

resource "aws_iam_policy" "document_upload_service_bucket_read_access" {
  name   = format("%s-document-upload-service-bucket-read-access", var.resource_name_prefixes.hyphens_lower)
  policy = data.aws_iam_policy_document.document_upload_service_bucket_read_access.json
}

resource "aws_iam_role_policy_attachment" "cat_api__document_upload_service_bucket_read_access" {
  role       = module.cat_api_task.task_role_name
  policy_arn = aws_iam_policy.document_upload_service_bucket_read_access.arn
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

resource "aws_security_group" "cat_api_lb" {
  name        = "${var.resource_name_prefixes.normal}:LB:CATAPI"
  description = "ALB for CAT API"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:LB:CATAPI"
  }
}

resource "aws_security_group_rule" "cat_api_lb__public_https_in" {
  description     = "Allow HTTPS from approved addresses into the CAT API LB"
  from_port       = 443
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
