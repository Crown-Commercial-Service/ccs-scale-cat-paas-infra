resource "aws_iam_role" "eventbridge_ppmt" {
  count = var.ppmt_enabled ? 1 : 0
  name  = "eventbridge-ppmt"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "TrustEventBridgeService",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_ppmt" {
  count = var.ppmt_enabled ? 1 : 0
  name  = "eventbridge-ppmt"
  role  = aws_iam_role.eventbridge_ppmt[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "ActionsForResource",
        "Effect" : "Allow",
        "Action" : [
          "events:PutEvents"
        ],
        "Resource" : [
          "arn:aws:events:eu-west-2:${var.ppmt_account}:event-bus/default"
        ]
      },
    ]
  })
}

resource "aws_cloudwatch_event_rule" "ecr_events" {
  count       = var.ppmt_enabled ? 1 : 0
  name        = "ecr-events"
  description = "ECR Events"

  event_pattern = jsonencode({
    detail-type = [
      "ECR Image Action"
    ]
  })
}

resource "aws_cloudwatch_event_target" "ecr_events" {
  count    = var.ppmt_enabled ? 1 : 0
  rule     = aws_cloudwatch_event_rule.ecr_events[count.index].name
  arn      = "arn:aws:events:eu-west-2:${var.ppmt_account}:event-bus/default"
  role_arn = aws_iam_role.eventbridge_ppmt[count.index].arn
}

resource "aws_cloudwatch_event_rule" "ecs_events" {
  count       = var.ppmt_enabled ? 1 : 0
  name        = "ecs-events"
  description = "ECS Events"

  event_pattern = jsonencode({
    detail-type = [
      "ECS Deployment State Change",
      "ECS Service Action",
      "ECS Task State Change"
    ]
  })
}

resource "aws_cloudwatch_event_target" "ecs_events" {
  count    = var.ppmt_enabled ? 1 : 0
  rule     = aws_cloudwatch_event_rule.ecs_events[count.index].name
  arn      = "arn:aws:events:eu-west-2:${var.ppmt_account}:event-bus/default"
  role_arn = aws_iam_role.eventbridge_ppmt[count.index].arn
}
