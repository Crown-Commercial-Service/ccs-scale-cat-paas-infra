output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.cat_full.ecs_cluster_arn
}

output "ingestion_bucket_id" {
  description = "Full name of the bucket which is to contain the ingestion objects"
  value       = module.ingestion_bucket.bucket_id
}

output "ingestion_bucket_write_objects_policy_document_json" {
  description = "JSON describing an IAM policy to allow writing of objects to the ingestion bucket"
  value       = module.ingestion_bucket.write_objects_policy_document_json
}

output "public_buyer_ui_cert_validation_records_required" {
  description = "Details of the cert validation recrods required for the public-facing Buyer UI certificate"
  value       = module.cat_full.public_buyer_ui_cert_validation_records_required
}

output "public_buyer_ui_cname_source" {
  description = "DNS record to CNAME to the Buyer UI in this stack"
  value       = module.cat_full.public_buyer_ui_cname_source
}


output "public_buyer_ui_cname_target" {
  description = "FQDN to which the public Buyer UI DNS CNAME should point"
  value       = module.cat_full.public_buyer_ui_cname_target
}
