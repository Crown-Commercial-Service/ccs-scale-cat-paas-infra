variable "environment" {}

variable "organisation" {}

variable "space" {}

variable "disk_quota" {
  default = 512
}

variable "healthcheck_timeout" {
  default = 10
}

variable "instances" {
  default = 2
}

variable "memory" {
  default = 1024
}

variable "region_domain" {
  default = "london.cloudapps.digital"
}
