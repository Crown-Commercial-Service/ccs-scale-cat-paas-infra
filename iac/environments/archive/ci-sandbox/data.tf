data "aws_wafv2_web_acl" "cas_web_acl" {
  name  = var.cas_web_acl_name
  scope = "REGIONAL"
}
