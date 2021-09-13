#########################################################
# Environment: INT
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source                = "../../modules/configs/deploy-all"
  space                 = "INT"
  environment           = "int"
  cf_username           = var.cf_username
  cf_password           = var.cf_password
  syslog_drain_url      = "https://d74f58fc-479f-413d-bb66-1cec772b5f5a-ls.logit.io:17256"
  postgres_service_plan = "small-ha-11"
}
