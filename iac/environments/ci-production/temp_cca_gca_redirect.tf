# TEMPORARY - safe to delete this file entirely once no longer needed.
# Redirects all traffic on the legacy CCA buyer_ui redirect host to its GCA equivalent, preserving path/query.
# Ticket: NCAS-XXXX
resource "aws_lb_listener_rule" "temp_redirect_production_contractawardservice_to_gca" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:544351764388:listener/app/CAS-EUW2-PRD-ALB-CASUI/e010406481ce59af/9f5f3be31c77e49a"
  priority     = 3

  condition {
    host_header {
      values = ["redirect.contractawardservice.crowncommercial.gov.uk"]
    }
  }

  action {
    type = "redirect"
    redirect {
      host        = "redirect.contractawardservice.gca.gov.uk"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
