#########################################################
# Cache: Redis
#
# Provision Redis cache for use by Buyer UI.
#########################################################
data "cloudfoundry_service" "redis" {
  name = "redis"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "redis-buyer-ui" {
  name         = "${var.environment}-ccs-scale-cat-redis-buyer-ui"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.service_plan]

  timeouts {
    create = var.create_timeout
    delete = var.delete_timeout
  }
}
