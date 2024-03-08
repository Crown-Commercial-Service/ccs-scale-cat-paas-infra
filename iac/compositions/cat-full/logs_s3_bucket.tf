locals {
  logs_bucket_name = "logs-bucket-${var.resource_name_prefixes.hyphens_lower}"
}

data "aws_iam_policy_document" "write_logs" {
  version = "2012-10-17"

  statement {
    sid = "AllowAlbPutLogs"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.elb_account_id}:root"]
    }

    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${local.logs_bucket_name}/access-logs/buyerui/AWSLogs/${var.aws_account_id}/*",
      "arn:aws:s3:::${local.logs_bucket_name}/connection-logs/buyerui/AWSLogs/${var.aws_account_id}/*",
      "arn:aws:s3:::${local.logs_bucket_name}/access-logs/catapi/AWSLogs/${var.aws_account_id}/*",
      "arn:aws:s3:::${local.logs_bucket_name}/connection-logs/catapi/AWSLogs/${var.aws_account_id}/*",
    ]
  }
}

module "logs_bucket" {
  source = "../../core/resource-groups/private-s3-bucket"

  bucket_name  = local.logs_bucket_name
  is_ephemeral = false
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = module.logs_bucket.bucket_id
  policy = data.aws_iam_policy_document.write_logs.json
}
