locals {
  resources = [{
    type       = "rds_db_instance"
    identifier = "cat"
    },
    {
      type         = "ecs_service"
      serviceName  = "buyer_ui"
      clusterName  = "${var.resource_name_prefixes.hyphens}-CAS"
      desiredCount = 1
    },
    {
      type         = "ecs_service"
      serviceName  = "cas_ui"
      clusterName  = "${var.resource_name_prefixes.hyphens}-CAS"
      desiredCount = 1
    },
    {
      type         = "ecs_service"
      serviceName  = "cat_api"
      clusterName  = "${var.resource_name_prefixes.hyphens}-CAS"
      desiredCount = 1
    }
  ]
}

module "start_stop" {
  count = var.start_stop ? 1 : 0

  source = "../../core/modules/environment-stop-start"

  resources              = local.resources
  start_schedule_enabled = var.start_schedule_enabled
}
