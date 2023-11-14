module "cat_full" {
  source = "../../compositions/cat-full"

  aws_account_id           = var.aws_account_id
  aws_region               = var.aws_region
  docker_image_tags        = var.docker_image_tags
  environment_is_ephemeral = var.environment_is_ephemeral
  environment_name         = var.environment_name
  resource_name_prefixes   = var.resource_name_prefixes
  task_container_configs   = var.task_container_configs
  vpc_cidr_block           = var.vpc_cidr_block
}
