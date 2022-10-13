#########################################################
# Environment: Bootstrap ALL (for custom domains etc)
#
# This is separate from the indeividual environment config 
# as we must be able to provision it independently upfront.
# N.B: Apex domains shared from LD org for all CaS environments
#########################################################

# module "sbx2-bootstrap" {
#   source                     = "../../modules/configs/boostrap"
#   space                      = "sandbox-2"
#   environment                = "sbx2"
#   cf_username                = var.cf_username
#   cf_password                = var.cf_password
#   subdomains                 = "sbx2.redirect.contractawardservice.crowncommercial.gov.uk"
# }

data "aws_ssm_parameter" "buyer_ui_domain" {
  name = "/cat/default/buyer-ui-domain"
}

# TODO: backport SBX2

module "bootstrap-dev" {
  source                     = "../../modules/bootstrap"
  space                      = "development"
  environment                = "dev"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "dev.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-sit" {
  source                     = "../../modules/bootstrap"
  space                      = "int"
  environment                = "int"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "sit.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-nft" {
  source                     = "../../modules/bootstrap"
  space                      = "nft"
  environment                = "nft"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "nft.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-uat" {
  source                     = "../../modules/bootstrap"
  space                      = "uat"
  environment                = "uat"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "uat.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-uat2" {
  source                     = "../../modules/bootstrap"
  space                      = "uat2"
  environment                = "uat2"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "uat2.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-pre" {
  source                     = "../../modules/bootstrap"
  space                      = "pre-production"
  environment                = "pre"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = "pre.${data.aws_ssm_parameter.buyer_ui_domain.value}"
}

module "bootstrap-prd" {
  source                     = "../../modules/bootstrap"
  space                      = "production"
  environment                = "prd"
  cf_username                = var.cf_username
  cf_password                = var.cf_password
  subdomains                 = data.aws_ssm_parameter.buyer_ui_domain.value
}
