#########################################################
# Autoscaler
#
# Provision Autoscaler for use.
#########################################################
data "cloudfoundry_service" "autoscaler" {
  name = "autoscaler"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "autoscaler" {
  name         = "${var.environment}-ccs-scale-cat-autoscaler"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.autoscaler.service_plans[var.service_plan]
}
