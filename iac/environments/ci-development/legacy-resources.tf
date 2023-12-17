locals {
  legacy_parameters_to_create = [
    "agreements-service-api-key",
    "auth-server-client-id",
    "auth-server-client-secret",
    "conclave-wrapper-api-key",
    "conclave-wrapper-identities-api-key",
    "document-upload-service-api-key",
    "document-upload-service-aws-access-key-id",
    "document-upload-service-aws-secret-key",
    "gcloud-search-api-token",
    "gcloud-token",
    "gov-uk-notify_api-key",
    "logit-api-key",
    "jaggaer-client-secret",
    "rollbar-access-token",
    "session-secret",
  ]
}

resource "aws_ssm_parameter" "legacy_parameter" {
  for_each = toset(local.legacy_parameters_to_create)

  name  = "/cas-dummy/${var.environment_name}/${each.key}"
  type  = "SecureString"
  value = "Dummy parameter"
  lifecycle {
    ignore_changes = [value]
  }
}
