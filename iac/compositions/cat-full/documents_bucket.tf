locals {
  documents_bucket_name = format("%s-ccs-scale-cat-tenders-s3-documents", var.resource_name_prefixes.hyphens_lower)
}

module "documents_bucket" {
  source = "../../core/resource-groups/private-s3-bucket"

  bucket_name  = local.documents_bucket_name
  is_ephemeral = var.environment_is_ephemeral
}

data "aws_iam_policy_document" "documents_bucket_full_access" {
  source_policy_documents = [
    module.documents_bucket.delete_objects_policy_document_json,
    module.documents_bucket.read_objects_policy_document_json,
    module.documents_bucket.write_objects_policy_document_json,
  ]
}

resource "aws_iam_policy" "documents_bucket_full_access" {
  name   = "documents-bucket-full-access"
  policy = data.aws_iam_policy_document.documents_bucket_full_access.json
}
