module "cas_ui" {
  source = "../../compositions/cas-ui"

  aws_account_id                          = var.aws_account_id
  aws_region                              = var.aws_region
  cas_ui_public_cert_attempt_validation   = var.cas_ui_public_cert_attempt_validation
  cas_ui_public_fqdn                      = var.cas_ui_public_fqdn
  cas_ui_ingress_cidr_safelist            = var.cas_ui_ingress_cidr_safelist
  cat_api_clients_security_group_id       = module.cat_full.cat_api_clients_security_group_id
  docker_image_tags                       = var.docker_image_tags
  ecr_repo_url                            = module.cat_full.ecr_repo_urls["cas-ui"]
  ecs_cluster_arn                         = module.cat_full.ecs_cluster_arn
  ecs_exec_policy_arn                     = module.cat_full.ecs_exec_policy_arn
  ecs_execution_role                      = module.cat_full.ecs_execution_role
  enable_lb_access_logs                   = var.enable_lb_access_logs
  enable_lb_connection_logs               = var.enable_lb_connection_logs
  enable_ecs_execute_command              = var.enable_ecs_execute_command
  environment_is_ephemeral                = var.environment_is_ephemeral
  environment_name                        = var.environment_name
  hosted_zone_cas_ui                      = var.hosted_zone_cas_ui
  resource_name_prefixes                  = var.resource_name_prefixes
  task_container_configs                  = var.task_container_configs
  redis_credentials                       = module.cat_full.redis_credentials
  session_cache_clients_security_group_id = module.cat_full.session_cache_clients_security_group_id
  service_subdomain_prefixes              = var.service_subdomain_prefixes
  subnets                                 = module.cat_full.subnets
  vpc_id                                  = module.cat_full.vpc_id
  depends_on                              = [module.cat_full]
}
