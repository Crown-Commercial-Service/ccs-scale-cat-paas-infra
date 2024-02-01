module "migrate_ingestion_bucket" {
  source = "../../core/modules/gpaas-s3-migrator"

  lambda_dist_bucket_id                            = aws_s3_bucket.lambda_dist.id
  migrator_name                                    = "ingestion"
  resource_name_prefixes                           = var.resource_name_prefixes
  target_bucket_id                                 = module.cat_full.ingestion_bucket_id
  target_bucket_write_objects_policy_document_json = module.cat_full.ingestion_bucket_write_objects_policy_document_json
}
