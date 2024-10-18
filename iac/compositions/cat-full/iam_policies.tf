data "aws_iam_policy_document" "ecs_exec_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "allow-ecs-exec-policy"
  description = "Enables ECS ExecuteCommand"
  policy      = data.aws_iam_policy_document.ecs_exec_policy.json
}

### Implementing the CAS UI IAM policies
#data "aws_iam_policy_document" "ecs_execution_log_permissions" {
#  # Note: We knowingly expect repeat "DescribeAllLogGroups" Sids, hence we use
#  # `override_` rather than `source_`
#  override_policy_documents = [
#    module.cas_ui_task.write_task_logs_policy_document_json,
#  ]
#}

#data "aws_iam_policy_document" "ecs_execution_pass_task_role_permissions" {
#  source_policy_documents = [
#    module.cas_ui_task.pass_task_role_policy_document_json,
#  ]
#}

#locals {
#  execution_role_policy_docs = {
#    "logs_cas_ui" : data.aws_iam_policy_document.ecs_execution_log_permissions.json,
#    "pass_task_role_cas_ui" : data.aws_iam_policy_document.ecs_execution_pass_task_role_permissions.json,
#  }
#}

#resource "aws_iam_role_policy" "ecs_execute__execution_role_permissions" {
#  for_each = local.execution_role_policy_docs

#  name   = "ecs-execution-permissions-${each.key}"
#  role   = aws_iam_role.ecs_execution_role.name
#  policy = each.value
#}
