resource "aws_wafv2_web_acl_association" "cas_buyer_ui_web_acl_association" {
  count        = var.cas_buyer_ui_lb_waf_enabled != false ? 1 : 0
  resource_arn = aws_lb.buyer_ui.arn
  web_acl_arn  = var.cas_web_acl_arn
}

resource "aws_wafv2_web_acl_association" "cas_cat_api_web_acl_association" {
  count        = var.cas_cat_api_lb_waf_enabled != false ? 1 : 0
  resource_arn = aws_lb.cat_api.arn
  web_acl_arn  = var.cas_web_acl_arn
}
