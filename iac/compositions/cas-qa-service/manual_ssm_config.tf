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
    "config.security.api-key",
    "external-services.agreements-service.api-key",
    "external-services.agreements-service.base-path",
    "external-services.agreements-service.data-templates-path",
    "external-services.tenders-api.api-key",
    "external-services.tenders-api.base-path",
    "rollbar.accessToken",
    "rollbar.env"
  ]
}

resource "aws_ssm_parameter" "manual_config" {
  for_each = toset(local.ssm_config_items)
  name     = "${var.ssm_parameter_name_prefix_qa}/${each.key}"
  type     = "SecureString"
  value    = "TO_BE_PROVIDED"

  lifecycle {
    # Allow the value to be updated without reversion
    ignore_changes = [
      value
    ]
  }
}
