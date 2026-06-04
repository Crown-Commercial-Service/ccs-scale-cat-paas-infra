output "public_cas_qa_cname_source" {
  description = "DNS record to CNAME to the cas QA in this stack"
  value       = var.cas_qa_public_fqdn
}

output "public_cas_qa_cname_target" {
  description = "FQDN to which the public cas QA DNS CNAME should point"
  value       = [for record in aws_route53_record.public_cas_qa : record.fqdn]
}

output "public_cas_qa_gca_cname_source" {
  description = "DNS record to CNAME to the cas QA GCA in this stack"
  value       = var.cas_qa_public_gca_fqdn
}

output "public_cas_qa_gca_cname_target" {
  description = "FQDN to which the public cas QA GCA DNS CNAME should point"
  value       = [for record in aws_route53_record.public_cas_qa_gca : record.fqdn]
}
