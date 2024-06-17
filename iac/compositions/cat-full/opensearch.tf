locals {
  search_domain_name = "${var.resource_name_prefixes.hyphens_lower}-search"
}

module "search_domain" {
  source = "../../core/resource-groups/opensearch-domain"

  domain_name            = local.search_domain_name
  ebs_volume_size_gib    = var.search_domain_volume_size_gib
  engine_version         = var.search_domain_engine_version
  instance_count         = var.search_domain_instance_count
  instance_type          = var.search_domain_instance_type
  resource_name_prefixes = var.resource_name_prefixes
  subnet_ids             = module.vpc.subnets.database.ids
  vpc_id                 = module.vpc.vpc_id
}
