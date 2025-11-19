variable "aws_account_id" {
  type        = string
  description = "AWS account into which to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "Region into which to deploy region-specific resources"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Opt to enable automatic minor version upgrades"
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Opt to allow major version upgrade (defaults to false)"
  default     = false
}

variable "cas_qa_lb_listener_acm_arn" {
  type        = string
  description = "The full ARN of the ACM certificate to association with the CAS QA LB Listener (should be the redirect ACM cert)"
  default     = "N/A"
}

variable "cas_qa_adopt_redirect_certificate" {
  type        = bool
  description = "Conditional to determine whether or not CAS QA should adopt the Redirect certificate (for the migration from Buyer UI to CAS QA - defaults to false)"
  default     = false
}

variable "cas_qa_base_cert_attempt_validation" {
  type        = bool
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `cas_qa_base_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "cas_qa_ingress_cidr_safelist" {
  type        = map(string)
  description = "Map of CIDR blocks from which to accept requests for the public-facing Load Balancer for the CAS QA, format {description: CIDR}"
  validation {
    condition     = length(var.cas_qa_ingress_cidr_safelist) <= 20
    error_message = "The cas_qa_ingress_cidr_safelist can have a maximum of 20 entries."
  }
}

variable "cas_qa_public_cert_attempt_validation" {
  type        = bool
  description = "If set to `false`, prevents Terraform from trying to validate the cert ownership - This will the the setting required when you first apply Terraform, to enable the process to finish cleanly. Once CNAME records have been created according to the output `public_cas_qa_cert_validation_records_required`, you can reset this variable to `true` and re-apply."
}

variable "cas_qa_public_fqdn" {
  type        = string
  description = "FQDN corresponding to the HOST header which will be present on all UI requests - This will be CNAMEd to the domain specified in the `hosted_zone_ui` variable"
}

variable "cas_qa_lb_waf_enabled" {
  type        = bool
  description = "Boolean value specifying whether or not the CAS QA LB WAF Should be enabled"
}

variable "cas_web_acl_arn" {
  type        = string
  description = "The ARN of the Web ACL (to be associated with enabled Load Balancers)"
}

variable "cat_api_clients_security_group_id" {
  type        = string
  description = "CAT API clients security group ID"
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance."
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
    cas_qa_http = string,
  })
  description = "Docker tag for deployment of each of the services from ECR"
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "Boolean to declare whether or not drop_invalid_header_fields should be enabled"
}

variable "lb_enable_deletion_protection" {
  type        = bool
  description = "Opt whether or not to enable deletion protection on Load Balancers"
}

variable "logs_bucket_id" {
  type        = string
  description = "The ID of the logs bucket (for logging on the Load Balancer)"
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

variable "hosted_zone_cas_qa" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the UI"
}


variable "hosted_zone_ui" {
  type = object({
    id   = string
    name = string
  })
  description = "Properties of the Hosted Zone (which must be in the same AWS account as the resources) into which we will place alias and cert validation records for the [env]-cas-ui"
}

variable "cas_qa_replication_group_enabled" {
  type        = bool
  description = "Boolean value to decide whether or not to enable Elasticache Replication Group"
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
    cas_qa = string,
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
    cas_qa = object({
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
