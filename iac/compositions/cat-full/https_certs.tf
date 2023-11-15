module "cat_api_cert" {
  source = "../../core/resource-groups/acm-certificate"

  domain_name    = local.fqdns.cat_api
  hosted_zone_id = var.hosted_zone.id
}
