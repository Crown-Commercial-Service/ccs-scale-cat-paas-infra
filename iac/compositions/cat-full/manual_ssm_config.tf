/*
  MANUAL CONFIG",
  -------------
  SSM parameters which must be provided to the environment by the operator,
  rather than being determined by Terraform.

  If your system needs THIS much config, it does suggest an excess of tightly-
  coupled and brittle dependencies. #justsaying
*/
locals {
  ssm_config_items = [
    "agreements-service-api-key",
    "agreements-service-api-url",
    "agreements-service-base-url",
    "auth-identity-base-url",
    "auth-server-base-url",
    "auth-server-client-id",
    "auth-server-client-secret",
    "auth-server-jwk-set-uri",
    "conclave-wrapper-api-base-url",
    "conclave-wrapper-api-key",
    "conclave-wrapper-identities-api-base-url",
    "conclave-wrapper-identities-api-key",
    "dashboard-banner",
    "document-upload-service-api-key",
    "document-upload-service-aws-access-key-id",
    "document-upload-service-aws-secret-key",
    "document-upload-service-get-base-url",
    "document-upload-service-s3-bucket",
    "document-upload-service-upload-base-url",
    "gcloud-index",
    "gcloud-search-api-token",
    "gcloud-search-api-url",
    "gcloud-services-api-url",
    "gcloud-supplier-api-url",
    "gcloud-token",
    "google-site-tag-id",
    "google-tag-manager-id",
    "gov-uk-notify-api-key",
    "gov-uk-notify-invalid-duns-template-id",
    "gov-uk-notify-target-email",
    "gov-uk-notify-template-id",
    "jaggaer-base-url",
    "jaggaer-client-id",
    "jaggaer-project-template-id",
    "jaggaer-itt-template-id",
    "jaggaer-self-service-id",
    "jaggaer-token-url",
    "login-director-url",
    "logit-api-key",
    "logit-environment",
    "jaggaer-client-secret",
    "oppertunities-s3-export-schedule",
    "oppertunities-s3-export-ui-link",
    "projects-to-opensearch-sync-schedule",
    "rollbar-access-token",
    "rollbar-environment",
    "rollbar-host",
    "session-secret",
  ]
}

resource "aws_ssm_parameter" "manual_config" {
  for_each = toset(local.ssm_config_items)
  name     = "${var.ssm_parameter_name_prefix}/${each.key}"
  type     = "SecureString"
  value    = "TO_BE_PROVIDED"

  lifecycle {
    # Allow the value to be updated without reversion
    ignore_changes = [
      value
    ]
  }
}
