#########################################################
# Environment: INT
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source                = "../../modules/configs/deploy-all"
  space                 = "nft"
  environment           = "nft"
  cf_username           = var.cf_username
  cf_password           = var.cf_password
  syslog_drain_url      = "https://204572d5-f8ba-45f1-9e81-55e89762f616-ls.logit.io:12111"
  postgres_service_plan = "medium-ha-11"
}
