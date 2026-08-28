output "cas_ui_base_cert_validation_records_required" {
  description = "Details of the cert validation recrods required for the [env]-cas-ui certificate"
  value       = local.cas_ui_base_cert_validations
}

output "public_cas_ui_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing cas UI certificate"
  value       = local.public_cas_ui_cert_validations
}

output "public_cas_ui_cname_source" {
  description = "DNS record to CNAME to the cas UI in this stack"
  value       = var.cas_ui_public_fqdn
}

output "public_cas_ui_cname_target" {
  description = "FQDN to which the public cas UI DNS CNAME should point"
  value       = aws_route53_record.cas_ui.fqdn
}

output "cas_ui_base_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the [env]-cas-ui GCA certificate"
  value       = local.cas_ui_base_gca_cert_validations
}

output "public_cas_ui_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing GCA cas UI certificate"
  value       = local.public_cas_ui_gca_cert_validations
}

output "public_cas_ui_gca_cname_source" {
  description = "DNS record to CNAME to the GCA cas UI in this stack"
  value       = var.cas_ui_public_gca_fqdn
}

output "public_cas_ui_gca_cname_target" {
  description = "FQDN to which the public GCA cas UI DNS CNAME should point"
  value       = aws_route53_record.cas_ui_gca.fqdn
}

output "public_cas_contractawardservice_gca_cert_validation_records_required" {
  description = "Details of the cert validation records required for the GCA contractawardservice alias certificate"
  value       = local.public_cas_contractawardservice_gca_cert_validations
}
