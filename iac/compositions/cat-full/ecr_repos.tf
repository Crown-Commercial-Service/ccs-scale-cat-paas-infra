# Note that including this module will create an IAM policy and an IAM group
# both named "allow-ecr-login-and-push" to which membership will permit the holder
# to perform `docker login` and `docker push` as per the documentation here:
#  https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/ecr_repository/README.md
#
module "ecr_repos" {
  source       = "../../core/resource-groups/ecr-repository-group"
  is_ephemeral = var.environment_is_ephemeral
  repository_names = [
    "buyer-ui",
    "cat-api",
  ]
}
