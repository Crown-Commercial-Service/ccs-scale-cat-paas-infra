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
  postgres_service_plan = "medium-ha-11"
  nginx_memory          = 2048
  nginx_instances       = 3
}
