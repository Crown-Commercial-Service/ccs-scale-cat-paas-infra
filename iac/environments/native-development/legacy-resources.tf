locals {
  legacy_parameters_to_create = [
    "conclave-wrapper-api-key",
    "conclave-wrapper-identities-api-key",
    "document-upload-service-api-key",
    "document-upload-service-aws-access-key-id",
    "document-upload-service-aws-secret-key",
    "gov-uk-notify_api-key",
    "jaggaer-client-secret",
    "rollbar-access-token",
  ]
}

resource "aws_ssm_parameter" "legacy_parameter" {
  for_each = toset(local.legacy_parameters_to_create)

  name  = "/cat-dummy/${var.environment_name}/${each.key}"
  type  = "SecureString"
  value = "Dummy parameter"
  lifecycle {
    ignore_changes = [value]
  }
}
