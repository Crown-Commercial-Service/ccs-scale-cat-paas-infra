locals {
  postgres_docker_image = "postgres:${var.rds_postgres_engine_version}-alpine"
}
