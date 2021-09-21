#########################################################
# Database: Tenders (CaT)
#
# Provision Tenders Postgres Database.
#########################################################
data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "postgres" {
  name         = "${var.environment}-ccs-scale-cat-tenders-pg-db"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]

  timeouts {
    create = var.postgres_create_timeout
    delete = var.postgres_delete_timeout
  }
}
