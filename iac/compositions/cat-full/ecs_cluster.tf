module "ecs_cluster" {
  source = "../../core/modules/ecs-cluster"

  cluster_name = "${var.resource_name_prefixes.hyphens}-CAS"
  execution_role = {
    "arn"  = aws_iam_role.ecs_execution_role.arn,
    "name" = aws_iam_role.ecs_execution_role.name
  }
  execution_role_policy_docs = {
    "ecr" : module.ecr_repos.pull_repo_images_policy_document_json
    "log" : data.aws_iam_policy_document.ecs_execution_log_permissions.json,
    "pass_task_role" : data.aws_iam_policy_document.ecs_execution_pass_task_role_permissions.json,
    "ssm" : data.aws_iam_policy_document.read_all_ssm_params.json,
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name        = "${var.resource_name_prefixes.hyphens_lower}-ecs-execution"
  description = "Role assumed by the ECS service during provision and setup of tasks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "ecs_execution_log_permissions" {
  # Note: We knowingly expect repeat "DescribeAllLogGroups" Sids, hence we use
  # `override_` rather than `source_`
  override_policy_documents = concat(
    [module.buyer_ui_task.write_task_logs_policy_document_json, module.cat_api_task.write_task_logs_policy_document_json],
    length(module.create_rds_postgres_tester) > 0 ? [module.create_rds_postgres_tester[0].write_task_logs_policy_document_json] : []
  )
}

data "aws_iam_policy_document" "ecs_execution_pass_task_role_permissions" {
  source_policy_documents = [
    module.buyer_ui_task.pass_task_role_policy_document_json,
    module.cat_api_task.pass_task_role_policy_document_json,
  ]
}

# With insane levels of config comes insane IAM policy
data "aws_iam_policy_document" "read_all_ssm_params" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadAllSSM"

    effect = "Allow"

    actions = [
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/*"
    ]
  }
}
