data "aws_iam_policy_document" "cat_api_read_secret_parameters" {
  version = "2012-10-17"

  statement {
    sid = "AllowCATAPIReadSecretParameterPaths"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = compact(distinct(values(var.cat_api_ssm_secret_paths)))
  }
}
