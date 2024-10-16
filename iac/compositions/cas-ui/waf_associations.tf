resource "aws_wafv2_web_acl_association" "cas_ui_web_acl_association" {
  count        = var.cas_ui_lb_waf_enabled == true ? 1 : 0
  resource_arn = aws_lb.cas_ui.arn
  web_acl_arn  = var.cas_web_acl_arn
}
