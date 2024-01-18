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

output "ingestion_bucket_id" {
  description = "Full name of the bucket which is to contain the ingestion objects"
  value       = module.ingestion_bucket.bucket_id
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

output "subnets" {
  description = "Properties relating to the four subnets"
  value       = module.vpc.subnets
}

output "vpc_id" {
  description = "ID of the VPC for the app"
  value       = module.vpc.vpc_id
}
