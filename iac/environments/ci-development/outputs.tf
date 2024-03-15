output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.cat_full.ecs_cluster_arn
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

output "public_cas_ui_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing Buyer UI certificate"
  value       = module.cat_full.public_cas_ui_cert_validation_records_required
}

output "public_cas_ui_cname_source" {
  description = "DNS record to CNAME to the Buyer UI in this stack"
  value       = module.cat_full.public_cas_ui_cname_source
}


output "public_cas_ui_cname_target" {
  description = "FQDN to which the public Buyer UI DNS CNAME should point"
  value       = module.cat_full.public_cas_ui_cname_target
}
