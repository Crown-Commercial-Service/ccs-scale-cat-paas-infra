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
  postgres_service_plan = "medium-ha-13"
  nginx_memory          = 2048
  nginx_instances       = 3
  redis_service_plan    = "large-ha-6_x"
}
