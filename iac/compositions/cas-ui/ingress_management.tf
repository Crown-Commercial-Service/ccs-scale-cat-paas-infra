/*resource "aws_ec2_managed_prefix_list" "cas_ui_ingress_safelist" {
  name           = "CAS UI LB ingress safelist"
  address_family = "IPv4"
  max_entries    = length(var.cas_ui_ingress_cidr_safelist)
}

resource "aws_ec2_managed_prefix_list_entry" "cas_ui_allowed" {
  for_each       = var.cas_ui_ingress_cidr_safelist
  cidr           = each.value
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.cas_ui_ingress_safelist.id
}*/
