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
  syslog_drain_url = "https://44f18302-59ca-4034-a82e-63f742e60a3e-ls.logit.io:12732"
  nginx_memory     = 1024
  nginx_instances  = 1
}