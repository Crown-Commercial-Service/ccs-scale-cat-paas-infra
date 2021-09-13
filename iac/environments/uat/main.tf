#########################################################
# Environment: INT
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source                = "../../modules/configs/deploy-all"
  space                 = "uat"
  environment           = "uat"
  cf_username           = var.cf_username
  cf_password           = var.cf_password
  syslog_drain_url      = "https://66a4e6b0-9dda-4047-bc50-b45b127124a4-ls.logit.io:12759"
  postgres_service_plan = "small-ha-11"
}
