locals {
  db_name     = "cas-qa-service"
  db_username = "postgres"
}

module "db" {
  source = "../../core/resource-groups/rds-postgres"

  allocated_storage_gb                  = var.rds_allocated_storage_gb
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  apply_immediately                     = var.rds_apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  backup_retention_period_days          = var.rds_backup_retention_period_days
  ca_cert_identifier                    = var.ca_cert_identifier
  db_instance_class                     = var.rds_db_instance_class
  db_name                               = local.db_name
  db_username                           = local.db_username
  iam_database_authentication_enabled   = var.rds_iam_database_authentication_enabled
  deletion_protection                   = var.deletion_protection
  postgres_engine_version               = var.rds_postgres_engine_version
  rds_backup_window                     = var.rds_backup_window
  rds_event_subscription_email_endpoint = var.rds_event_subscription_email_endpoint
  rds_event_subscription_enabled        = var.rds_event_subscription_enabled
  rds_maintenance_window                = var.rds_maintenance_window
  resource_name_prefixes                = var.resource_name_prefixes
  skip_final_snapshot                   = var.rds_skip_final_snapshot
  subnet_ids                            = module.vpc.subnets.database.ids
  vpc_id                                = module.vpc.vpc_id
}