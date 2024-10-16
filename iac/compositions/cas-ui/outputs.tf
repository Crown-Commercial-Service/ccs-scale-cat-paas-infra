/*output "public_cas_ui_cert_validation_records_required" {
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
}*/