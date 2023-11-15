locals {
  fqdns = {
    cat_api = "${var.service_subdomain_prefixes.cat_api}.${var.hosted_zone.name}"
  }
}
