# TEMPORARY - safe to delete this file entirely once no longer needed.
# Redirects all traffic on the legacy CCA buyer_ui redirect host to its GCA equivalent, preserving path/query.
# Ticket: NCAS-XXXX

resource "aws_lb_listener_rule" "temp_redirect_dev_contractawardservice_ui_to_gca" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:610544551367:listener/app/CAS-EUW2-DEV-ALB-CASUI/9173b579c40b9c5a/a67fdbdb608dcc9a"
  priority     = 4

  condition {
    host_header {
      values = ["dev.redirect.contractawardservice.crowncommercial.gov.uk"]
    }
  }

  action {
    type = "redirect"
    redirect {
      host        = "dev.redirect.contractawardservice.gca.gov.uk"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
