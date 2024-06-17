variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "buyer_ui_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the Buyer UI, format {description: CIDR}"
  validation {
    condition     = length(var.buyer_ui_ingress_cidr_safelist) <= 20
    error_message = "The buyer_ui_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "buyer_ui_public_cert_attempt_validation" {
  type        = bool
  default     = true
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `public_buyer_ui_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "buyer_ui_public_fqdn" {
  type        = string
  description = "FQDN corresponding to the HOST header which will be present on all UI requests - This will be CNAMEd to the domain specified in the `hosted_zone_ui` variable"
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance."
}

variable "cas_buyer_ui_lb_waf_enabled" {
  type        = bool
  description = "Boolean value specifying whether or not the Buyer UI LB WAF Should be enabled"
}

variable "cas_cat_api_lb_waf_enabled" {
  type        = bool
  description = "Boolean value specifying whether or not the CAT API LB WAF Should be enabled"
}

variable "cas_web_acl_arn" {
  type        = string
  description = "The ARN of the Web ACL (to be associated with enabled Load Balancers)"
}

variable "cat_api_config_flags_devmode" {
  type        = string
  description = "Service-specific config" # TODO Source clearer explanation
}

variable "cat_api_eetime_enabled" {
  type        = string
  description = "Service-specific config" # TODO Source clearer explanation
}

variable "cat_api_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the CAT API, format {description: CIDR}"
  validation {
    condition     = length(var.cat_api_ingress_cidr_safelist) <= 20
    error_message = "The cat_api_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "cat_api_log_level" {
  type        = string
  description = "Log Level for Java CAT API service"
}

variable "cat_api_resolve_buyer_users_by_sso" {
  type        = bool
  description = "Service-specific config" # TODO Source clearer explanation
}

variable "default_ssl_policy" {
  type        = string
  description = "The default SSL Policy to apply to the Load Balancers"
}

variable "deletion_protection" {
  type        = bool
  description = "Boolean to opt in/out of enabling deletion protection. The DB cannot be deleted when set to true"
}

variable "docker_image_tags" {
  type = object({
    buyer_ui_http = string,
    cat_api_http  = string,
  })
  description = "Docker tag for deployment of each of the services from ECR"
}

variable "elasticache_cluster_parameter_group_name" {
  type        = string
  description = "The Parameter Group Name for the Elasticache cluster"
}

variable "enable_ecs_execute_command" {
  type        = bool
  description = "If 1, enables ecs exec on all ecs services"
  default     = true
}

variable "enable_lb_access_logs" {
  type        = bool
  description = "If 1, enables ALB access logging"
  default     = true
}

variable "enable_lb_connection_logs" {
  type        = bool
  description = "If 1, enables ALB connection logging"
  default     = true
}

variable "environment_is_ephemeral" {
  type        = bool
  description = "If true, indicates that the environment is expected to be destroyed from time to time - Allows for (e.g.) `force_destroy` on S3 buckets"
}

variable "environment_name" {
  type        = string
  description = "Name for this environment, to distinguish it from other environments for this system / application."
}

variable "hosted_zone_api" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the API"
}

variable "hosted_zone_ui" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the UI"
}

variable "lb_enable_deletion_protection" {
  type        = bool
  description = "Opt whether or not to enable deletion protection on Load Balancers"
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

variable "replication_group_enabled" {
  type        = bool
  description = "Boolean value to decide whether or not to enable Elasticache Replication Group"
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

variable "search_domain_instance_type" {
  type        = string
  description = "Type of compute instance to provide for the OpenSearch domain"
}

variable "search_domain_volume_size_gib" {
  type        = number
  description = "Size (in GiB) of the EBS volume to attach to each Opensearch instance"
}

variable "service_subdomain_prefixes" {
  type = object({
    buyer_ui = string,
    cat_api  = string,
  })
}

variable "session_redis_engine_version" {
  type        = string
  description = "Version of Redis engine for the user session cache"
}

variable "session_redis_node_type" {
  type        = string
  description = "Type of node to deploy for the user session cache"
}

variable "session_redis_num_cache_nodes" {
  type        = number
  description = "Number of nodes to instantiate for the user session cache"
}

variable "ssm_parameter_name_prefix" {
  type        = string
  description = "Prefix for each SSM parameter created"
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
