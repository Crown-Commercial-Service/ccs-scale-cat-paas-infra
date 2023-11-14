# Note that including this module will create an IAM policy and an IAM group
# both named "run-update-service" to which membership will permit the holder
# to execute the `update_service.py` script to scale up / down and redeploy
# ECS services as per:
#  https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/update_service/update_service.py

module "run_update_service" {
  source = "../../core/modules/run-update-service"

  ecs_cluster_arn = module.ecs_cluster.cluster_arn
}
