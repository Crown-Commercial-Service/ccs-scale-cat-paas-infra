locals {
  db_name     = "cat"
  db_username = "postgres"
}

module "db" {
  source = "../../core/resource-groups/rds-postgres"

  allocated_storage_gb                = var.rds_allocated_storage_gb
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.rds_apply_immediately
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  backup_retention_period_days        = var.rds_backup_retention_period_days
  ca_cert_identifier                  = var.ca_cert_identifier
  db_instance_class                   = var.rds_db_instance_class
  db_name                             = local.db_name
  db_username                         = local.db_username
  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  postgres_engine_version             = var.rds_postgres_engine_version
  rds_backup_window                   = var.rds_backup_window
  rds_event_subscription_enabled      = var.rds_event_subscription_enabled
  rds_maintenance_window              = var.rds_maintenance_window
  resource_name_prefixes              = var.resource_name_prefixes
  skip_final_snapshot                 = var.rds_skip_final_snapshot
  subnet_ids                          = module.vpc.subnets.database.ids
  vpc_id                              = module.vpc.vpc_id
}

module "create_rds_postgres_tester" {
  count = var.environment_name != "ci-production" && var.environment_name != "production" ? 1 : 0
  source = "../../core/modules/create-rds-postgres-tester"

  aws_account_id                         = var.aws_account_id
  aws_region                             = var.aws_region
  db_name                                = local.db_name
  db_connection_url_ssm_param_arn        = module.db.postgres_connection_url_ssm_parameter_arn
  ecs_execution_role                     = {
    arn  = aws_iam_role.ecs_execution_role.arn
    name = aws_iam_role.ecs_execution_role.name
  }
  ecs_cluster_arn                        = module.ecs_cluster.cluster_arn
  postgres_docker_image                  = local.postgres_docker_image
  security_group_ids                     = [
    aws_security_group.cat_api_tasks.id,
    module.db.db_clients_security_group_id,
  ]
  subnet_id                              = module.vpc.subnets.application.ids[0]
  vpc_id                                 = module.vpc.vpc_id
}
