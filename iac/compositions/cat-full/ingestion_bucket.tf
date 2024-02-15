module "ingestion_bucket" {
  source = "../../core/resource-groups/private-s3-bucket"

  bucket_name  = "ingest-bucket-${var.resource_name_prefixes.hyphens_lower}"
  is_ephemeral = var.environment_is_ephemeral
}

data "aws_iam_policy_document" "ingestion_bucket_full_access" {
  source_policy_documents = [
    module.ingestion_bucket.delete_objects_policy_document_json,
    module.ingestion_bucket.read_objects_policy_document_json,
    module.ingestion_bucket.write_objects_policy_document_json,
  ]
}

resource "aws_iam_policy" "ingestion_bucket_full_access" {
  name   = "ingestion-bucket-full-access"
  policy = data.aws_iam_policy_document.ingestion_bucket_full_access.json
}
