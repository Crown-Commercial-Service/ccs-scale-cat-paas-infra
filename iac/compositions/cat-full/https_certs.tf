module "buyer_ui_cert" {
  source = "../../core/resource-groups/acm-certificate"

  domain_name    = local.fqdns.buyer_ui
  hosted_zone_id = var.hosted_zone.id
}

module "cat_api_cert" {
  source = "../../core/resource-groups/acm-certificate"

  domain_name    = local.fqdns.cat_api
  hosted_zone_id = var.hosted_zone.id
}
