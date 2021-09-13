variable "organisation" {}

variable "space" {}

variable "environment" {}

variable "postgres_instance_name" {}

variable "postgres_service_plan" {}

variable "cf_username" {
  sensitive = true
}

variable "cf_password" {
  sensitive = true
}