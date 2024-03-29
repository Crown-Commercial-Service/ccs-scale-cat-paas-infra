variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "cas_ui_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the CAS UI, format {description: CIDR}"
  validation {
    condition     = length(var.cas_ui_ingress_cidr_safelist) <= 20
    error_message = "The cas_ui_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "cas_ui_public_cert_attempt_validation" {
  type        = bool
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `public_cas_ui_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "cas_ui_public_fqdn" {
  type        = string
  description = "FQDN corresponding to the HOST header which will be present on all UI requests - This will be CNAMEd to the domain specified in the `hosted_zone_ui` variable"
}

variable "cat_api_clients_security_group_id" {
  type        = string
  description = "CAT API clients security group ID"
}

variable "docker_image_tags" {
  type = object({
    cas_ui_http = string,
  })
  description = "Docker tag for deployment of each of the services from ECR"
}

variable "ecr_repo_url" {
  type        = string
  description = "CAS-UI ECR repository url"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ECS cluster ARN"
}

variable "ecs_execution_role" {
  type = object({
    arn  = string
    name = string
  })
  description = "ECS execution IAM role"
}

variable "ecs_exec_policy_arn" {
  type        = string
  description = "ECS EXEC policy arn"
}

variable "elb_account_id" {
  type        = string
  description = " ID of the AWS account for Elastic Load Balancing for your Region, default is Europe - London"
  default     = "652711504416"
}

variable "enable_lb_access_logs" {
  type        = bool
  description = "If 1, enables access logs"
  default     = false
}

variable "enable_lb_connection_logs" {
  type        = bool
  description = "If 1, enables connection logs"
  default     = false
}

variable "enable_ecs_execute_command" {
  type        = bool
  description = "If 1, enables ecs exec on all ecs services"
  default     = false
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

variable "hosted_zone_cas_ui" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the UI"
}

variable "redis_credentials" {
  type = object({
    host     = string,
    password = string,
    port     = number
  })
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

variable "service_subdomain_prefixes" {
  type = object({
    cas_ui = string,
  })
}

variable "session_cache_clients_security_group_id" {
  type        = string
  description = "Session cache clients secujrity group ID"
}

variable "subnets" {
  type = object({
    public = object({
      ids = list(string)
    })
    web = object({
      ids = list(string)
    })
  })
  description = "VPC subnet IDs"
}

# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
variable "task_container_configs" {
  type = object({
    cas_ui = object({
      http_cpu     = number,
      http_memory  = number,
      total_cpu    = number,
      total_memory = number,
    }),
  })
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}
