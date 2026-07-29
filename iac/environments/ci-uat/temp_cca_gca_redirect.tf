# TEMPORARY - safe to delete this file entirely once no longer needed.
# Two independent rules with separate lifecycles - either can be removed on its own.

# Ticket: NCAS-1851
# Redirects 1specific CCA path to its GCA equivalent
# All other paths on this host remains unaffected
resource "aws_lb_listener_rule" "temp_redirect_uat_contractawardservice_ui_to_gca" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:172432939940:listener/app/CAS-EUW2-UAT-ALB-CASUI/bd9cf2d8a64c78f5/038bd048f56a5792"
  priority     = 3

  condition {
    host_header {
      values = ["uat-contractawardservice-ui.crowncommercial.gov.uk"]
    }
  }

  condition {
    path_pattern {
      values = ["/digital-outcomes/opportunities/opportunity-details/project/38465"]
    }
  }

  action {
    type = "redirect"
    redirect {
      host        = "uat-contractawardservice-ui.gca.gov.uk"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

# Ticket: NCAS-XXXX
# Redirects all traffic on the legacy CCA buyer_ui redirect host to its GCA equivalent, preserving path/query.
# Same whole-host pattern as ci-development / ci-pre / ci-production.
resource "aws_lb_listener_rule" "temp_redirect_uat_redirect_contractawardservice_to_gca" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:172432939940:listener/app/CAS-EUW2-UAT-ALB-CASUI/bd9cf2d8a64c78f5/038bd048f56a5792"
  priority     = 4

  condition {
    host_header {
      values = ["uat.redirect.contractawardservice.crowncommercial.gov.uk"]
    }
  }

  action {
    type = "redirect"
    redirect {
      host        = "uat.redirect.contractawardservice.gca.gov.uk"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
