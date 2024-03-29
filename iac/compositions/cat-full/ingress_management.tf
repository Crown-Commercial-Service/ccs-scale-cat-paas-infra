resource "aws_ec2_managed_prefix_list" "buyer_ui_ingress_safelist" {
  name           = "Buyer UI LB ingress safelist"
  address_family = "IPv4"
  max_entries    = length(var.buyer_ui_ingress_cidr_safelist)
}

resource "aws_ec2_managed_prefix_list_entry" "buyer_ui_allowed" {
  for_each       = var.buyer_ui_ingress_cidr_safelist
  cidr           = each.value
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.buyer_ui_ingress_safelist.id
}

resource "aws_ec2_managed_prefix_list" "cat_api_ingress_safelist" {
  name           = "CAT API LB ingress safelist"
  address_family = "IPv4"
  max_entries    = length(var.cat_api_ingress_cidr_safelist)
}

resource "aws_ec2_managed_prefix_list_entry" "cat_api_allowed" {
  for_each       = var.cat_api_ingress_cidr_safelist
  cidr           = each.value
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.cat_api_ingress_safelist.id
}
