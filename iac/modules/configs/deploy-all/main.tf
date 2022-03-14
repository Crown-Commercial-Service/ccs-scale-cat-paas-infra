#########################################################
# Config: deploy-all
#
# This configuration will deploy all components.
#########################################################
module "tenders-db" {
  source                  = "../../tenders-db"
  organisation            = var.organisation
  space                   = var.space
  environment             = var.environment
  postgres_instance_name  = var.postgres_instance_name
  postgres_service_plan   = var.postgres_service_plan
  postgres_create_timeout = var.agreements_db_create_timeout
  postgres_delete_timeout = var.agreements_db_delete_timeout
  cf_username             = var.cf_username
  cf_password             = var.cf_password
}

module "logit-ups" {
  source       = "../../logit-ups"
  organisation = var.organisation
  space        = var.space
  environment  = var.environment
  cf_username  = var.cf_username
  cf_password  = var.cf_password
}

module "ip-router" {
  source       = "../../ip-router"
  organisation = var.organisation
  space        = var.space
  environment  = var.environment
  memory       = var.nginx_memory
  instances    = var.nginx_instances
}

module "redis" {
  source         = "../../redis"
  organisation   = var.organisation
  space          = var.space
  environment    = var.environment
  service_plan   = var.redis_service_plan
  create_timeout = var.redis_create_timeout
  delete_timeout = var.redis_delete_timeout
}

module "s3" {
  source         = "../../s3"
  organisation   = var.organisation
  space          = var.space
  environment    = var.environment
}
