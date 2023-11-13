module "cat_full" {
  source = "../../compositions/cat-full"

  environment_is_ephemeral = var.environment_is_ephemeral
}
