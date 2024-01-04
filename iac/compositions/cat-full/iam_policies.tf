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
