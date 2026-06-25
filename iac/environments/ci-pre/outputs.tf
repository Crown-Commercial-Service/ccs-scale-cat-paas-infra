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
  value       = module.cas_ui.public_cas_ui_cert_validation_records_required
}

output "public_cas_ui_cname_source" {
  description = "DNS record to CNAME to the Buyer UI in this stack"
  value       = module.cas_ui.public_cas_ui_cname_source
}


output "public_cas_ui_cname_target" {
  description = "FQDN to which the public Buyer UI DNS CNAME should point"
  value       = module.cas_ui.public_cas_ui_cname_target
}

output "public_buyer_ui_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing GCA Buyer UI certificate"
  value       = module.cat_full.public_buyer_ui_gca_cert_validation_records_required
}

output "public_buyer_ui_gca_cname_source" {
  description = "DNS record to CNAME to the GCA Buyer UI in this stack"
  value       = module.cat_full.public_buyer_ui_gca_cname_source
}

output "public_buyer_ui_gca_cname_target" {
  description = "FQDN to which the public GCA Buyer UI DNS CNAME should point"
  value       = module.cat_full.public_buyer_ui_gca_cname_target
}

output "cas_ui_base_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the [env]-cas-ui GCA certificate"
  value       = module.cas_ui.cas_ui_base_gca_cert_validation_records_required
}

output "public_cas_ui_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing GCA cas UI certificate"
  value       = module.cas_ui.public_cas_ui_gca_cert_validation_records_required
}

output "public_cas_ui_gca_cname_source" {
  description = "DNS record to CNAME to the GCA cas UI in this stack"
  value       = module.cas_ui.public_cas_ui_gca_cname_source
}

output "public_cas_ui_gca_cname_target" {
  description = "FQDN to which the public GCA cas UI DNS CNAME should point"
  value       = module.cas_ui.public_cas_ui_gca_cname_target
}

output "public_cas_contractawardservice_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the GCA contractawardservice alias certificate"
  value       = module.cas_ui.public_cas_contractawardservice_gca_cert_validation_records_required
}
