variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "docker_image_tags" {
  type = object({
    buyer_ui_http = string,
  })
  description = "Docker tag for deployment of each of the services from ECR"
}

variable "environment_is_ephemeral" {
  type        = bool
  description = "If true, indicates that the environment is expected to be destroyed from time to time - Allows for (e.g.) `force_destroy` on S3 buckets"
  default     = false
}

variable "environment_name" {
  type        = string
  description = "Name for this environment, to distinguish it from other environments for this system / application."
}

# See naming convention doc:
#   https://crowncommercialservice.atlassian.net/wiki/spaces/GPaaS/pages/3561685032/AWS+3+Tier+Reference+Architecture
variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
variable "task_container_configs" {
  type = object({
    buyer_ui = object({
      http_cpu     = number,
      http_memory  = number,
      total_cpu    = number,
      total_memory = number,
    })
  })
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to assign to the VPC"
}
