#########################################################
# Environment: SBX2
#
# Deploy CaT resources
#########################################################
module "deploy-all" {
  source           = "../../modules/configs/deploy-all"
  space            = "sandbox-2"
  environment      = "sbx2"
  cf_username      = var.cf_username
  cf_password      = var.cf_password
  nginx_memory     = 1024
  nginx_instances  = 1
}
