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
  postgres_service_plan = "small-ha-11"
  nginx_instances       = 3
}
