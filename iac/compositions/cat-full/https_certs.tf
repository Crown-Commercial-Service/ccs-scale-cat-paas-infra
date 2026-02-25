module "cat_api_cert" {
  source = "../../core/resource-groups/acm-certificate"

  domain_name    = var.hosted_zone_api.name
  hosted_zone_id = var.hosted_zone_api.id
}

module "cat_api_gca_cert" {
  source = "../../core/resource-groups/acm-certificate"

  domain_name    = var.hosted_zone_api_gca.name
  hosted_zone_id = var.hosted_zone_api_gca.id
}
