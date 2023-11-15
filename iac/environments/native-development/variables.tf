variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "cat_api_environment" {
  type = object({
    agreements-service-base-url              = string,
    auth-server-jwk-set-uri                  = string,
    conclave-wrapper-api-base-url            = string,
    conclave-wrapper-identities-api-base-url = string,
    dev_mode                                 = bool,
    document-upload-service-get-base-url     = string,
    document-upload-service-s3-bucket        = string,
    document-upload-service-upload-base-url  = string,
    eetime_enabled                           = bool,
    gov-uk-notify_invalid-duns-template-id   = string,
    gov-uk-notify_target-email               = string,
    gov-uk-notify_template-id                = string,
    jaggaer-base-url                         = string,
    jaggaer-client-id                        = string,
    jaggaer-itt-template-id                  = string,
    jaggaer-project-template-id              = string,
    jaggaer-self-service-id                  = string,
    jaggaer-token-url                        = string,
    log_level                                = string,
    oppertunities-s3-export-schedule         = string,
    oppertunities-s3-export-ui-link          = string,
    projects-to-opensearch-sync-schedule     = string,
    resolve_buyer_users_by_sso               = bool,
    rollbar-environment                      = string,
  })
  description = "Environment variable values specific to the CAT API"
}

variable "cat_api_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the CAT API, format {description: CIDR}"
  validation {
    condition     = length(var.cat_api_ingress_cidr_safelist) <= 20
    error_message = "The cat_api_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "cat_api_ssm_secret_paths" {
  type = object({
    conclave-wrapper-api-key                  = string,
    conclave-wrapper-identities-api-key       = string,
    document-upload-service-api-key           = string,
    document-upload-service-aws-access-key-id = string,
    document-upload-service-aws-secret-key    = string,
    gov-uk-notify_api-key                     = string,
    jaggaer-client-secret                     = string,
    rollbar-access-token                      = string,
  })
  description = "Paths to SSM parameters containing secrets for the CAT API"
}

variable "docker_image_tags" {
  type = object({
    buyer_ui_http = string,
    cat_api_http  = string,
  })
  description = "Docker tag for deployment of each of the services from ECR"
}

variable "environment_is_ephemeral" {
  type        = bool
  description = "If true, indicates that the environment is expected to be destroyed from time to time - Allows for (e.g.) `force_destroy` on S3 buckets"
}

variable "environment_name" {
  type        = string
  description = "Name for this environment, to distinguish it from other environments for this system / application."
}

variable "hosted_zone" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records"
}

variable "rds_allocated_storage_gb" {
  type        = number
  description = "Storage allocation in GiB"
  default     = 10
}

variable "rds_backup_retention_period_days" {
  type        = number
  description = "Number of days for which to keep backups"
  default     = 14
}

variable "rds_db_instance_class" {
  type        = string
  description = "Type of DB instance"
  default     = "db.t3.small"
}

variable "rds_postgres_engine_version" {
  type        = string
  description = "Version number of db engine to use"
  default     = "14.6"
}

variable "rds_skip_final_snapshot" {
  type        = string
  description = "Whether or not to skip the creation of a final snapshot of the db upon deletion"
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

variable "search_domain_engine_version" {
  type        = string
  description = "Version of OpenSearch engine to deploy"
}

variable "search_domain_instance_count" {
  type        = number
  description = "Number of instances in the OpenSearch cluster"
}

variable "search_domain_volume_size_gib" {
  type        = number
  description = "Size (in GiB) of the EBS volume to attach to each Opensearch instance"
}

variable "service_subdomain_prefixes" {
  type = object({
    cat_api = string,
  })
}

# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
variable "task_container_configs" {
  type = object({
    buyer_ui = object({
      http_cpu     = number,
      http_memory  = number,
      total_cpu    = number,
      total_memory = number,
    }),
    cat_api = object({
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
