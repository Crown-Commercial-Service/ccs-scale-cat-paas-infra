module "cat_full" {
  source = "../../compositions/cat-full"

  auto_minor_version_upgrade               = var.auto_minor_version_upgrade
  aws_account_id                           = var.aws_account_id
  aws_region                               = var.aws_region
  buyer_ui_ingress_cidr_safelist           = var.buyer_ui_ingress_cidr_safelist
  buyer_ui_public_cert_attempt_validation  = var.buyer_ui_public_cert_attempt_validation
  buyer_ui_public_fqdn                     = var.buyer_ui_public_fqdn
  buyer_ui_redirect_r53_to_cas_ui          = var.buyer_ui_redirect_r53_to_cas_ui
  ca_cert_identifier                       = var.ca_cert_identifier
  cas_buyer_ui_lb_waf_enabled              = var.cas_buyer_ui_lb_waf_enabled
  cas_cat_api_lb_waf_enabled               = var.cas_cat_api_lb_waf_enabled
  cas_web_acl_arn                          = data.aws_wafv2_web_acl.cas_web_acl.arn
  cat_api_config_flags_devmode             = var.cat_api_config_flags_devmode
  cat_api_eetime_enabled                   = var.cat_api_eetime_enabled
  cat_api_ingress_cidr_safelist            = var.cat_api_ingress_cidr_safelist
  cat_api_log_level                        = var.cat_api_log_level
  cat_api_resolve_buyer_users_by_sso       = var.cat_api_resolve_buyer_users_by_sso
  default_ssl_policy                       = var.default_ssl_policy
  deletion_protection                      = var.deletion_protection
  docker_image_tags                        = var.docker_image_tags
  drop_invalid_header_fields               = var.drop_invalid_header_fields
  elasticache_cluster_parameter_group_name = var.elasticache_cluster_parameter_group_name
  enable_lb_access_logs                    = var.enable_lb_access_logs
  enable_lb_connection_logs                = var.enable_lb_connection_logs
  enable_ecs_execute_command               = var.enable_ecs_execute_command
  environment_is_ephemeral                 = var.environment_is_ephemeral
  environment_name                         = var.environment_name
  hosted_zone_api                          = var.hosted_zone_api
  hosted_zone_ui                           = var.hosted_zone_ui
  lb_enable_deletion_protection            = var.lb_enable_deletion_protection
  rds_allocated_storage_gb                 = var.rds_allocated_storage_gb
  rds_backup_retention_period_days         = var.rds_backup_retention_period_days
  rds_backup_window                        = var.rds_backup_window
  rds_db_instance_class                    = var.rds_db_instance_class
  rds_event_subscription_email_endpoint    = var.rds_event_subscription_email_endpoint
  rds_event_subscription_enabled           = var.rds_event_subscription_enabled
  rds_iam_database_authentication_enabled  = var.rds_iam_database_authentication_enabled
  rds_maintenance_window                   = var.rds_maintenance_window
  rds_postgres_engine_version              = var.rds_postgres_engine_version
  rds_skip_final_snapshot                  = var.rds_skip_final_snapshot
  replication_group_enabled                = var.replication_group_enabled
  resource_name_prefixes                   = var.resource_name_prefixes
  search_domain_engine_version             = var.search_domain_engine_version
  search_domain_instance_count             = var.search_domain_instance_count
  search_domain_instance_type              = var.search_domain_instance_type
  search_domain_volume_size_gib            = var.search_domain_volume_size_gib
  service_subdomain_prefixes               = var.service_subdomain_prefixes
  session_redis_engine_version             = var.session_redis_engine_version
  session_redis_node_type                  = var.session_redis_node_type
  session_redis_num_cache_nodes            = var.session_redis_num_cache_nodes
  ssm_parameter_name_prefix                = var.ssm_parameter_name_prefix
  task_container_configs                   = var.task_container_configs
  vpc_cidr_block                           = var.vpc_cidr_block
  ### Below are the CAS UI specific variables - TODO: Refactor
  cas_ui_ingress_cidr_safelist             = var.cas_ui_ingress_cidr_safelist
  cas_ui_lb_waf_enabled                    = var.cas_ui_lb_waf_enabled
  cas_ui_public_cert_attempt_validation    = var.cas_ui_public_cert_attempt_validation
  cas_ui_public_fqdn                       = var.cas_ui_public_fqdn
  cas_ui_replication_group_enabled         = var.replication_group_enabled
  ecs_exec_policy_arn                      = module.cat_full.ecs_exec_policy_arn # Update this
  ecs_execution_role                       = module.cat_full.ecs_execution_role # Update this
  hosted_zone_cas_ui                       = var.hosted_zone_cas_ui
  logs_bucket_id                           = module.cat_full.logs_bucket_id # Update this
  redis_credentials                        = module.cat_full.redis_credentials # Update this
  session_cache_clients_security_group_id  = module.cat_full.session_cache_clients_security_group_id # Update this
  subnets                                  = module.cat_full.subnets # Update this
  vpc_id                                   = module.cat_full.vpc_id # Update this
}
