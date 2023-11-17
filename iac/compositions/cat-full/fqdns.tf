locals {
  fqdns = {
    buyer_ui = "${var.service_subdomain_prefixes.buyer_ui}.${var.hosted_zone.name}"
    cat_api  = "${var.service_subdomain_prefixes.cat_api}.${var.hosted_zone.name}"
  }
}
