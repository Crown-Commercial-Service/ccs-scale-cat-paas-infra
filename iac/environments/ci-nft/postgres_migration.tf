locals {
  # Get the AZ suffixes
  cat_az_suffix = substr(module.cat_full.db_availability_zone, -1, 1)

  # The migration processes are singular - we don't need multi-AZ here
  application_subnet_a_cidr_block = module.cat_full.subnets.application.cidr_blocks["a"]
  application_subnet_a_id         = module.cat_full.subnets.application.az_ids["a"]
}

# Variable declarations - Located in this file so that they may be removed from the project
# along with this file, post-migration
#
variable "cf_config" {
  type = object({
    api_endpoint        = string
    cf_cli_docker_image = string
    db_service_instance = string
    org                 = string
    space               = string
  })
  description = "Parameters for configuring the CloudFoundry interactions of this migrator's extract task"
}

variable "postgres_docker_image" {
  type        = string
  description = "Canonical name of Docker image from which to run Postgres psql utility"
}

# Network ACL overrides - Located in this file so that they may be removed from the project
# along with this file, post-migration
#
# Undocumented weird port 2222 outbound requirement for `cf conduit` (appears to be an ssh-like
# connection used during authentication with GPaaS)
#
resource "aws_network_acl_rule" "application__allow_2222_everywhere_out" {
  cidr_block = "0.0.0.0/0"
  egress     = true
  from_port  = 2222
  # Note that due to the ACL / rule structure, this outbound rule is applied
  # to both application subnets even though we only require it to be applied
  # to the "a" subnet. All this migrator code should be removed post-migration
  # and so it's deemed that the minor security infraction presented by this
  # situation does not justify a complete re-architecture of the ACL model
  # in the four-tier-vpc module.
  network_acl_id = module.cat_full.network_acl_ids.application
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 15000
  to_port        = 2222
}

resource "aws_network_acl_rule" "public__allow_2222_application_a_in" {
  cidr_block     = local.application_subnet_a_cidr_block
  egress         = false
  from_port      = 2222
  network_acl_id = module.cat_full.network_acl_ids.public
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 15000
  to_port        = 2222
}

resource "aws_network_acl_rule" "public__allow_2222_everywhere_out" {
  cidr_block = "0.0.0.0/0"
  egress     = true
  from_port  = 2222
  # See comment in application__allow_2222_everywhere_out above
  network_acl_id = module.cat_full.network_acl_ids.public
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 15100
  to_port        = 2222
}

# The actual migrator
#
module "migrate_postgres" {
  source = "../../core/modules/gpaas-postgres-migrator"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  cf_config      = var.cf_config

  count_rows_tables = [
    "assessment_dimension_criteria",
    "assessment_dimension_submission_types",
    "assessment_dimension_weighting",
    "assessment_results",
    "assessment_selection_details",
    "assessment_selection_results",
    "assessment_selections",
    "assessment_taxon_dimensions",
    "assessment_taxons",
    "assessment_tool_dimensions",
    "assessment_tool_submission_group",
    "assessment_tools",
    "assessments",
    "buyer_user_details",
    "cap_load_jobs",
    "cap_load_locations",
    "cap_load_resources",
    "cap_load_scalability",
    "cap_load_service_capability",
    "contract_details",
    "dimension_submission_types",
    "dimension_valid_values",
    "dimensions",
    "document_template_sources",
    "document_templates",
    "document_uploads",
    "gcloud_assessment_results",
    "gcloud_assessments",
    "journeys",
    "load_capability_locations",
    "load_capability_resources",
    "load_capability_scalability",
    "load_capability_services",
    "load_pricing",
    "lot_requirement_taxons",
    "organisation_mapping",
    "procurement_event_history",
    "procurement_events",
    "procurement_projects",
    "project_user_mapping",
    "question_and_answer",
    "requirement_taxons",
    "requirements",
    "shedlock",
    "std_calculation_rules",
    "std_exclusion_policy",
    "submission_group",
    "submission_types",
    "supplier_link",
    "supplier_selections",
    "supplier_submissions",
    "task_history",
    "tasks"
  ]

  db_clients_security_group_id = module.cat_full.db_clients_security_group_id
  ecs_cluster_arn              = module.cat_full.ecs_cluster_arn
  ecs_execution_role           = module.cat_full.ecs_execution_role
  efs_subnet_ids = []
  # Comment out for first run
  #  module.cat_full.subnets.application.az_ids["a"],
  #  module.cat_full.subnets.application.az_ids["b"]
  #]
  migrator_name                          = "cat"
  postgres_docker_image                  = var.postgres_docker_image
  resource_name_prefixes                 = var.resource_name_prefixes
  subnet_id                              = local.application_subnet_a_id
  target_db_connection_url_ssm_param_arn = module.cat_full.db_connection_url_ssm_param_arn
  vpc_id                                 = module.cat_full.vpc_id
}
