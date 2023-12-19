output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.ecs_cluster.cluster_arn
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
