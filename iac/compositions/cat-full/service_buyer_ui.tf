module "buyer_ui_task" {
  source = "../../core/resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region

  container_definitions = {
    http = {
      cpu                   = var.task_container_configs.buyer_ui.http_cpu
      environment_variables = [
        # TODO set up env vars
      ]
      essential                    = true
      healthcheck_command          = "tbc" # TODO set up container healthcheck
      image                        = "${module.ecr_repos.repository_urls["buyer-ui"]}:${var.docker_image_tags.buyer_ui_http}"
      log_group_name               = "${var.environment_name}-buyer-ui-nginx" # Must exist already
      memory                       = var.task_container_configs.buyer_ui.http_memory
      mounts                       = []
      override_command             = null
      port                         = 8080
      secret_environment_variables = [
        # TODO set up secret env vars
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

  # TODO load_balancer

  network_configuration {
    assign_public_ip = false
    security_groups  = [
      # TODO Set up SGs
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
