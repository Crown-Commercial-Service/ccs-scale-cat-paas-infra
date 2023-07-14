#########################################################
# Opensearch
#
# Provision Opensearch for use.
#########################################################
data "cloudfoundry_service" "opensearch" {
  name = "opensearch"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "opensearch" {
  name         = "${var.environment}-ccs-scale-cat-opensearch"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.opensearch.service_plans[var.service_plan]
}
