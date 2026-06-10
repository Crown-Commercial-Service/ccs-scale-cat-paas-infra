module "backup_vault" {
  source    = "../../core/modules/backup_vault_crossregion"
  providers = { aws = aws, aws.secondary_region = aws.secondary_region }

  aws_region            = var.aws_region
  backup_environment_id = var.backup_environment_id
  backup_kms_key_id     = var.backup_kms_key_id
}
