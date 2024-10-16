variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Opt to enable automatic minor version upgrades"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Opt to allow major version upgrade (defaults to false)"
  default     = false
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

variable "buyer_ui_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
}

variable "buyer_ui_public_cert_attempt_validation" {
  type        = bool
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `public_buyer_ui_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "buyer_ui_public_fqdn" {
  type        = string
  description = "FQDN corresponding to the HOST header which will be present on all UI requests - This will be CNAMEd to the domain specified in the `hosted_zone_ui` variable"
}

variable "buyer_ui_redirect_r53_to_cas_ui" {
  type        = bool
  description = "Conditional to determine whether or not the R53 record for the Buyer UI should be redirected to CAS UI (as part of the CAS UI migration - defaults to false)"
  default     = false
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

variable "cat_api_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
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

variable "drop_invalid_header_fields" {
  type        = bool
  description = "Boolean to declare whether or not drop_invalid_header_fields should be enabled"
}

variable "elasticache_cluster_parameter_group_name" {
  type        = string
  description = "The Parameter Group Name for the Elasticache cluster"
}

variable "elb_account_id" {
  type        = string
  description = " ID of the AWS account for Elastic Load Balancing for your Region, default is Europe - London"
  default     = "652711504416"
}

variable "lb_enable_deletion_protection" {
  type        = bool
  description = "Opt whether or not to enable deletion protection on Load Balancers"
}

variable "enable_lb_access_logs" {
  type        = bool
  description = "If 1, enables access logs"
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

variable "logs_bucket_policy_include_cas_ui" {
  type        = bool
  description = "Conditional to determine whether or not the logs bucket policy includes CAS UI"
  default     = true
}

variable "rds_apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately or in the next maintenance window"
  default     = true
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

variable "rds_backup_window" {
  type        = string
  description = "The daily time range in which automated backups are created (if they are enabled)"
}

variable "rds_db_instance_class" {
  type        = string
  description = "Type of DB instance"
  default     = "db.t3.small"
}

variable "rds_event_subscription_email_endpoint" {
  type        = string
  description = "The email address to send RDS Event Subscription notifications to"
}

variable "rds_event_subscription_enabled" {
  type        = bool
  description = "Boolean to determine whether or not to enable RDS Event Subscription (defaults to false)"
}

variable "rds_iam_database_authentication_enabled" {
  type        = bool
  description = "Whether to enable IAM database authentication for the API db"
  default     = false
}

variable "rds_maintenance_window" {
  type        = string
  description = "The window in which RDS Maintenance should be performed (if enabled)"
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
    }),
  })
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to assign to the VPC"
}

### Implementing CAS UI vars
variable "cas_ui_adopt_redirect_certificate" {
  type        = bool
  description = "Conditional to determine whether or not CAS UI should adopt the Redirect certificate (for the migration from Buyer UI to CAS UI - defaults to false)"
  default     = false
}

variable "cas_ui_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the CAS UI, format {description: CIDR}"
  validation {
    condition     = length(var.cas_ui_ingress_cidr_safelist) <= 20
    error_message = "The cas_ui_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "cas_ui_lb_listener_acm_arn" {
  type        = string
  description = "The full ARN of the ACM certificate to association with the CAS UI LB Listener (should be the redirect ACM cert)"
  default     = "N/A"
}

variable "cas_ui_lb_waf_enabled" {
  type        = bool
  description = "Boolean value specifying whether or not the CAS UI LB WAF Should be enabled"
}

variable "cas_ui_public_cert_attempt_validation" {
  type        = bool
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `public_cas_ui_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "cas_ui_public_fqdn" {
  type        = string
  description = "FQDN corresponding to the HOST header which will be present on all UI requests - This will be CNAMEd to the domain specified in the `hosted_zone_ui` variable"
}

variable "cas_ui_replication_group_enabled" {
  type        = bool
  description = "Boolean value to decide whether or not to enable Elasticache Replication Group"
}

variable "ecs_exec_policy_arn" {
  type        = string
  description = "ECS EXEC policy arn"
}

variable "ecs_execution_role" {
  type = object({
    arn  = string
    name = string
  })
  description = "ECS execution IAM role"
}

variable "hosted_zone_cas_ui" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the UI"
}

variable "logs_bucket_id" {
  type        = string
  description = "The ID of the logs bucket (for logging on the Load Balancer)"
}

variable "redis_credentials" {
  type = object({
    host     = string,
    password = string,
    port     = number
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

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}
