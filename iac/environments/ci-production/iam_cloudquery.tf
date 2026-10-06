resource "aws_iam_role" "cloudquery_role" {
  name               = "gca_cloudquery_role"
  description        = "CloudQuery Role for cross-account access"
  assume_role_policy = data.aws_iam_policy_document.cloudquery_trust.json
}

data "aws_iam_policy_document" "cloudquery_trust" {
  statement {
    sid     = "CloudQueryTrustAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.cloudquery_aws_account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.cloudquery_external_id]
    }
  }
}

resource "aws_iam_policy" "cloudquery_policy" {
  name        = "gca-cloudquery-policy"
  description = "Allow CloudQuery access to account resources"
  policy      = data.aws_iam_policy_document.cloudquery_policy.json
}

data "aws_iam_policy_document" "cloudquery_policy" {
  version = "2012-10-17"

  statement {
    effect = "Deny"
    actions = [
      "cloudformation:GetTemplate",
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "ec2:GetConsoleOutput",
      "ec2:GetConsoleScreenshot",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "kinesis:Get*",
      "lambda:GetFunction",
      "logs:GetLogEvents",
      "s3:GetObject",
      "sdb:Select*",
      "sqs:ReceiveMessage",
      "secretsmanager:GetSecretValue",
      "ssm:GetCommandInvocation",
      "ssm:GetParameter*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "cloudquery_policy" {
  role       = aws_iam_role.cloudquery_role.name
  policy_arn = aws_iam_policy.cloudquery_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudquery_readonly" {
  role       = aws_iam_role.cloudquery_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

variable "cloudquery_aws_account_id" {
  type        = string
  description = "AWS account ID permitted to assume the CloudQuery role"
}

variable "cloudquery_external_id" {
  type        = string
  sensitive   = true
  description = "External ID required for CloudQuery to assume the role"
}

output "cloudquery_role_arn" {
  value       = aws_iam_role.cloudquery_role.arn
  description = "ARN of the CloudQuery IAM role"
}
