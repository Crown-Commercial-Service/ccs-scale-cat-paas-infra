# TEMPORARY - safe to delete this file entirely once no longer needed.
# Redirects all traffic on the legacy CCA buyer_ui redirect host to its GCA equivalent, preserving path/query.
# Ticket: NCAS-1865
resource "aws_lb_listener_rule" "temp_redirect_pre_contractawardservice_ui_to_gca" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:715926644738:listener/app/CAS-EUW2-PRE-ALB-CASUI/e5455282efb65218/c126389c2aa9ccbb"
  priority     = 3

  condition {
    host_header {
      values = ["pre.redirect.contractawardservice.crowncommercial.gov.uk"]
    }
  }

  action {
    type = "redirect"
    redirect {
      host        = "pre.redirect.contractawardservice.gca.gov.uk"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
