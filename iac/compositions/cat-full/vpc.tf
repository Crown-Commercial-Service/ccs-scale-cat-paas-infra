locals {
  database_ports = [
    { db_type : "opensearch", port : 443 },
    { db_type : "postgres", port : 5432 },
  ]
}

module "vpc" {
  source = "../../core/modules/four-tier-vpc"

  aws_region             = var.aws_region
  database_ports         = local.database_ports
  resource_name_prefixes = var.resource_name_prefixes
  vpc_cidr_block         = var.vpc_cidr_block
}
