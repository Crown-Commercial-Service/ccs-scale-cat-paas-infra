# Variable declarations - Located in this file so that they may be removed from the project
# along with this file, post-migration
#

# Passing in public keys via SSM
variable "db_bastion_instance_public_key_ssm_parameter_name" {
  type        = string
  description = "Name of the SSM Parameter containing the DB Bastion Instance Public Key"
}

variable "vpc_scanner_instance_public_key_ssm_parameter_name" {
  type        = string
  description = "Name of the SSM Parameter containing the VPC Scanner Instance Public Key"
}

data "aws_ssm_parameter" "db_bastion_instance_public_key" {
  name = var.db_bastion_instance_public_key_ssm_parameter_name
}

data "aws_ssm_parameter" "vpc_scanner_instance_public_key" {
  name = var.vpc_scanner_instance_public_key_ssm_parameter_name
}

# Set variables
variable "ithc_operative_cidr_safelist" {
  type        = list(string)
  description = "List of CIDR ranges to be allowed to access the EC2 instances"
}

variable "db_bastion_instance_root_device_size_gb" {
  type        = number
  description = "Size in GB of the root device on the DB Bastion instance"
  default     = 100
}

variable "db_bastion_instance_type" {
  type        = string
  description = "Instance type for the VPC Scanner"
  default     = "t3.small"
}

variable "vpc_scanner_instance_root_device_size_gb" {
  type        = number
  description = "Size in GB of the root device on the VPC Scanner instance"
  default     = 100
}

variable "vpc_scanner_instance_type" {
  type        = string
  description = "Instance type for the VPC Scanner"
  default     = "t3.small"
}

module "ithc_ingress" {
  source = "../../core/modules/ithc-ingress-caution"

  database_subnet_az_ids                  = module.cat_full.subnets.database.az_ids
  database_subnet_cidr_blocks             = module.cat_full.subnets.database.cidr_blocks
  database_subnets_nacl_id                = module.cat_full.network_acl_ids.database
  db_bastion_instance_public_key          = data.aws_ssm_parameter.db_bastion_instance_public_key.value
  db_bastion_instance_root_device_size_gb = var.db_bastion_instance_root_device_size_gb
  db_bastion_instance_subnet_cidr_block   = module.cat_full.subnets.public.cidr_blocks["b"]
  db_bastion_instance_subnet_id           = module.cat_full.subnets.public.az_ids["b"]
  db_bastion_instance_type                = var.db_bastion_instance_type
  db_clients_security_group_ids = [
    module.cat_full.db_clients_security_group_id,
  ]
  ithc_operative_cidr_safelist             = var.ithc_operative_cidr_safelist
  public_subnets_nacl_id                   = module.cat_full.network_acl_ids.public
  resource_name_prefixes                   = var.resource_name_prefixes
  vpc_cidr_block                           = var.vpc_cidr_block
  vpc_id                                   = module.cat_full.vpc_id
  vpc_scanner_instance_public_key          = data.aws_ssm_parameter.vpc_scanner_instance_public_key.value
  vpc_scanner_instance_root_device_size_gb = var.vpc_scanner_instance_root_device_size_gb
  vpc_scanner_instance_subnet_id           = module.cat_full.subnets.public.az_ids["a"]
  vpc_scanner_instance_type                = var.vpc_scanner_instance_type
}

output "db_bastion_public_dns" {
  description = "Public DNS name of the DB Bastion instance"
  value       = module.ithc_ingress.db_bastion_public_dns
}

output "ithc_audit_iam_user_arn" {
  description = "ARN of the IAM user created for ITHC audit"
  value       = module.ithc_ingress.ithc_audit_iam_user_arn
}

output "vpc_scanner_public_dns" {
  description = "Public DNS name of the VPC Scanner instance"
  value       = module.ithc_ingress.vpc_scanner_public_dns
}
