locals {
  // These are known secret parameters which we shouldn't try to retrieve
  // because ECS will use their ARN to retrieve at runtime
  ssm_secret_parameter_names = [
    "conclave-wrapper-api-key",
    "conclave-wrapper-identities-api-key",
    "document-upload-service-api-key",
    "document-upload-service-aws-access-key-id",
    "document-upload-service-aws-secret-key",
    "gov-uk-notify_api-key",
    "jaggaer-client-secret",
    "rollbar-access-token",
  ]
  ssm_parameters_to_retrieve = {
    for param, path in var.ssm_parameter_paths : param => path
    if !contains(local.ssm_secret_parameter_names, param)
  }

  ssm_secret_parameters = {
    for param, path in var.ssm_parameter_paths : param => path
    if contains(local.ssm_secret_parameter_names, param)
  }
}

data "aws_ssm_parameter" "parameter" {
  for_each = local.ssm_parameters_to_retrieve
  name     = each.value
}

data "aws_iam_policy_document" "read_secret_parameters" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadSecretParameterPaths"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = values(local.ssm_secret_parameters)
  }
}
