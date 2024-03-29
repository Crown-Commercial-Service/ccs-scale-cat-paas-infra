variable "organisation" {
  default = "ccs-scale-cat"
}

variable "space" {}

variable "environment" {}

variable "postgres_instance_name" {
  default = "tenders-pg-db"
}

variable "postgres_service_plan" {
  default = "tiny-unencrypted-13"
}

variable "opensearch_service_plan" {
  default = "tiny-1"
}

variable "autoscaler_service_plan" {
  default = "autoscaler-free-plan"
}

variable "agreements_db_create_timeout" {
  default = "30m"
}

variable "agreements_db_delete_timeout" {
  default = "30m"
}

variable "cf_username" {
  sensitive = true
}

variable "cf_password" {
  sensitive = true
}

variable "nginx_memory" {
  default = 1024
}

variable "nginx_instances" {
  default = 2
}

variable "redis_service_plan" {
  default = "small-ha-6_x"
}

variable "redis_create_timeout" {
  default = "30m"
}

variable "redis_delete_timeout" {
  default = "30m"
}
