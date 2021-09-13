variable "organisation" {
  default = "ccs-scale-cat"
}

variable "space" {}

variable "environment" {}

variable "postgres_instance_name" {
  default = "tenders-pg-db"
}

variable "postgres_service_plan" {
  default = "tiny-unencrypted-11"
}

variable "cf_username" {
  sensitive = true
}

variable "cf_password" {
  sensitive = true
}

variable "syslog_drain_url" {}
