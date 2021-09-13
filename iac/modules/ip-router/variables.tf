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
  default = 1
}

variable "memory" {
  default = 256
}

variable "region_domain" {
  default = "london.cloudapps.digital"
}
