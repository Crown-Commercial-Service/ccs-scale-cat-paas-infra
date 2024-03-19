output "cat_api_clients_security_group_id" {
  description = "CAT API clients security group ID"
  value       = aws_security_group.cat_api_clients.id
}

output "db_availability_zone" {
  description = "Availability zone for the RDS instance"
  value       = module.db.availability_zone
}

output "db_clients_security_group_id" {
  description = "ID of the security group whose membership allows a connection to the Postgres db"
  value       = module.db.db_clients_security_group_id
}

output "db_connection_url_ssm_param_arn" {
  description = "ARN of the SSM param which contains the connection url for the database"
  value       = module.db.postgres_connection_url_ssm_parameter_arn
}

output "ecr_repo_urls" {
  description = "ECR repo urls"
  value       = module.ecr_repos.repository_urls
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_execution_role" {
  description = "Details of the role used for ECS Execution, task setup etc"
  value = {
    arn  = aws_iam_role.ecs_execution_role.arn
    name = aws_iam_role.ecs_execution_role.name
  }
}

output "ecs_exec_policy_arn" {
  description = "ECS exec policy arn"
  value       = aws_iam_policy.ecs_exec_policy.arn
}

output "ingestion_bucket_id" {
  description = "Full name of the bucket which is to contain the ingestion objects"
  value       = module.ingestion_bucket.bucket_id
}

output "ingestion_bucket_write_objects_policy_document_json" {
  description = "JSON describing an IAM policy to allow writing of objects to the ingestion bucket"
  value       = module.ingestion_bucket.write_objects_policy_document_json
}

output "network_acl_ids" {
  description = "Object containing the IDs of each of the Network ACLS"
  value       = module.vpc.network_acl_ids
}

output "public_buyer_ui_cert_validation_records_required" {
  description = "Details of the cert validation recrods required for the public-facing Buyer UI certificate"
  value       = local.public_buyer_ui_cert_validations
}

output "public_buyer_ui_cname_source" {
  description = "DNS record to CNAME to the Buyer UI in this stack"
  value       = var.buyer_ui_public_fqdn
}

output "public_buyer_ui_cname_target" {
  description = "FQDN to which the public Buyer UI DNS CNAME should point"
  value       = aws_route53_record.buyer_ui.fqdn
}

output "redis_credentials" {
  description = "Redis credentials"
  sensitive   = true
  value       = local.redis_credentials
}

output "session_cache_clients_security_group_id" {
  description = "Session cache clients security group ID"
  value       = module.session_cache.clients_security_group_id
}

output "subnets" {
  description = "Properties relating to the four subnets"
  value       = module.vpc.subnets
}

output "vpc_id" {
  description = "ID of the VPC for the app"
  value       = module.vpc.vpc_id
}
