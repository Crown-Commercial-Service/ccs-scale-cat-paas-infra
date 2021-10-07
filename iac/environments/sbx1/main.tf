#########################################################
# Environment: SBX1
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source           = "../../modules/configs/deploy-all"
  space            = "sandbox"
  environment      = "sbx1"
  cf_username      = var.cf_username
  cf_password      = var.cf_password
  nginx_memory     = 1024
  nginx_instances  = 1
}
