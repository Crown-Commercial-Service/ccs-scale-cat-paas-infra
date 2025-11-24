output "public_cas_qa_cert_validation_records_required" {
  description = "Details of the cert validation records required for the public-facing cas QA certificate"
  value       = local.public_cas_qa_cert_validations
}

output "public_cas_qa_cname_source" {
  description = "DNS record to CNAME to the cas QA in this stack"
  value       = var.cas_qa_public_fqdn
}

output "public_cas_qa_cname_target" {
  description = "FQDN to which the public cas QA DNS CNAME should point"
  value       = aws_route53_record.cas_qa.fqdn
}
