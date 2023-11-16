data "aws_iam_policy_document" "read_secret_parameters" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadSecretParameterPaths"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = compact(distinct(concat(
      values(var.buyer_ui_ssm_secret_paths),
      values(var.cat_api_ssm_secret_paths),
    )))
  }
}
