locals {
  redis_credentials = {
    host     = module.session_cache.redis_host,
    password = var.replication_group_enabled == true ? module.session_cache.redis_auth_token : "" # "",
    port     = module.session_cache.redis_port,
  }
}

resource "aws_ssm_parameter" "vcap_services" {
  name        = "${var.ssm_parameter_name_prefix}/vcap-services"
  description = "VCAP services"
  type        = "SecureString"
  value       = jsonencode(local.buyer_ui_vcap_object)
}

module "session_cache" {
  source = "../../core/resource-groups/elasticache-redis"

  cluster_id                                = "buyer-ui-sessions"
  elasticache_cluster_apply_immediately     = true
  elasticache_cluster_parameter_group_name  = var.elasticache_cluster_parameter_group_name
  engine_version                            = var.session_redis_engine_version
  node_type                                 = var.session_redis_node_type
  num_cache_nodes                           = var.session_redis_num_cache_nodes
  replication_group_enabled                 = var.replication_group_enabled
  resource_name_prefixes                    = var.resource_name_prefixes
  subnet_ids                                = module.vpc.subnets.web.ids
  vpc_id                                    = module.vpc.vpc_id
}

resource "random_password" "session_secret" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "session_secret" {
  name        = "tf-session-secret-key"
  description = "Secret key for signing Buyer UI sessions"
  type        = "SecureString"
  value       = random_password.session_secret.result
}

data "aws_iam_policy_document" "read_session_secret" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadSessionSecret"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      aws_ssm_parameter.session_secret.arn,
    ]
  }
}
