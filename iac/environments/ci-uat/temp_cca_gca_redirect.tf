# TEMPORARY - safe to delete this file entirely once no longer needed.
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
