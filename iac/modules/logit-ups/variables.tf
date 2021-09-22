variable "logit_service_broker_name" {
  default = "logit-ssl-drain"
}

variable "environment" {}

variable "organisation" {}

variable "space" {}

variable "syslog_drain_url" {}

variable "cf_username" {
  sensitive = true
}

variable "cf_password" {
  sensitive = true
}
