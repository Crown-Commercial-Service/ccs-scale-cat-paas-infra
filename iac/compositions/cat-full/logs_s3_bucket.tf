module "logs_bucket" {
  source = "../../core/resource-groups/private-s3-bucket"

  bucket_name  = "logs-bucket-${var.resource_name_prefixes.hyphens_lower}"
  is_ephemeral = false
}
