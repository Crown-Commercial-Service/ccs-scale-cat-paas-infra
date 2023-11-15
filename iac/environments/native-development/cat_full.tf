module "cat_full" {
  source = "../../compositions/cat-full"

  aws_account_id                = var.aws_account_id
  aws_region                    = var.aws_region
  cat_api_environment           = var.cat_api_environment
  cat_api_ingress_cidr_safelist = var.cat_api_ingress_cidr_safelist
  cat_api_ssm_secret_paths = {
    conclave-wrapper-api-key                  = aws_ssm_parameter.legacy_parameter["conclave-wrapper-api-key"].arn,
    conclave-wrapper-identities-api-key       = aws_ssm_parameter.legacy_parameter["conclave-wrapper-identities-api-key"].arn,
    document-upload-service-api-key           = aws_ssm_parameter.legacy_parameter["document-upload-service-api-key"].arn,
    document-upload-service-aws-access-key-id = aws_ssm_parameter.legacy_parameter["document-upload-service-aws-access-key-id"].arn,
    document-upload-service-aws-secret-key    = aws_ssm_parameter.legacy_parameter["document-upload-service-aws-secret-key"].arn,
    gov-uk-notify_api-key                     = aws_ssm_parameter.legacy_parameter["gov-uk-notify_api-key"].arn,
    jaggaer-client-secret                     = aws_ssm_parameter.legacy_parameter["jaggaer-client-secret"].arn,
    rollbar-access-token                      = aws_ssm_parameter.legacy_parameter["rollbar-access-token"].arn,
  }
  docker_image_tags                = var.docker_image_tags
  environment_is_ephemeral         = var.environment_is_ephemeral
  environment_name                 = var.environment_name
  hosted_zone                      = var.hosted_zone
  rds_allocated_storage_gb         = var.rds_allocated_storage_gb
  rds_backup_retention_period_days = var.rds_backup_retention_period_days
  rds_db_instance_class            = var.rds_db_instance_class
  rds_postgres_engine_version      = var.rds_postgres_engine_version
  rds_skip_final_snapshot          = var.rds_skip_final_snapshot
  resource_name_prefixes           = var.resource_name_prefixes
  search_domain_engine_version     = var.search_domain_engine_version
  search_domain_instance_count     = var.search_domain_instance_count
  search_domain_volume_size_gib    = var.search_domain_volume_size_gib
  service_subdomain_prefixes       = var.service_subdomain_prefixes
  task_container_configs           = var.task_container_configs
  vpc_cidr_block                   = var.vpc_cidr_block
}
