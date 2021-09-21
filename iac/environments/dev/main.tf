#########################################################
# Environment: DEV
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source                = "../../modules/configs/deploy-all"
  space                 = "development"
  environment           = "dev"
  cf_username           = var.cf_username
  cf_password           = var.cf_password
  syslog_drain_url      = "https://44f18302-59ca-4034-a82e-63f742e60a3e-ls.logit.io:12732"
  postgres_service_plan = "small-ha-11"
}
