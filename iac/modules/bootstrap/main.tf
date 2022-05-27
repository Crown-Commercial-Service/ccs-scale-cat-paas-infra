#########################################################
# Custom DNS subdomain config
#########################################################

data "cloudfoundry_service" "cdn_route" {
  name = "cdn-route"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "cdn_route" {
  name         = "${var.environment}-ccs-scale-cat-buyer-ui-cdn-route"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.cdn_route.service_plans["cdn-route"]
  json_params  = "{\"domain\": \"${var.subdomains}\"}"
}