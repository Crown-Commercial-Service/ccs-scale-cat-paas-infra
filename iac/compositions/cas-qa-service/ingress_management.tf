resource "aws_ec2_managed_prefix_list" "cas_qa_ingress_safelist" {
  name           = "CAS QA LB ingress safelist"
  address_family = "IPv4"
  max_entries    = length(var.cas_qa_ingress_cidr_safelist)
}

resource "aws_ec2_managed_prefix_list_entry" "cas_qa_allowed" {
  for_each       = var.cas_qa_ingress_cidr_safelist
  cidr           = each.value
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.cas_qa_ingress_safelist.id
}
