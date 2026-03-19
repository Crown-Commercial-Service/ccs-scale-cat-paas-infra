resource "aws_acm_certificate" "external_cas_qa" {
  domain_name       = "ext.${var.cas_qa_public_fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "external_cas_qa" {
  for_each = {
    for dvo in aws_acm_certificate.external_cas_qa.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_cas_qa.id
}

resource "aws_acm_certificate_validation" "external_cas_qa" {
  certificate_arn         = aws_acm_certificate.external_cas_qa.arn
  validation_record_fqdns = [for record in aws_route53_record.external_cas_qa : record.fqdn]
}

resource "aws_lb_listener_certificate" "external_cas_qa" {
  listener_arn    = aws_lb_listener.cas_qa.arn
  certificate_arn = aws_acm_certificate.external_cas_qa.arn
}

resource "aws_lb" "cas_qa_nlb" {
  name                             = "${var.resource_name_prefixes.hyphens}-NLB-CASQA"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = var.subnets.public.ids
  security_groups                  = [aws_security_group.cas_qa_nlb.id]
}

resource "aws_lb_listener" "cas_qa_https" {
  load_balancer_arn = aws_lb.cas_qa_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cas_qa_alb_tg.arn
  }
}

resource "aws_lb_target_group" "cas_qa_alb_tg" {
  name        = "${var.resource_name_prefixes.hyphens}-TG-CASQA-ALB"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    port                = "443"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
    protocol            = "https"
  }
}

resource "aws_lb_target_group_attachment" "cas_qa_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.cas_qa_alb_tg.arn
  target_id        = aws_lb.cas_qa.arn
  port             = 443
}

#This is needed for return traffic back through the NLB and onto the external IP
resource "aws_network_acl_rule" "web_allow_https_public_in" {
  network_acl_id = var.nacl_web_id
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 443
  to_port        = 443
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5500
}

resource "aws_route53_record" "cas_qa_nlb" {
  name            = "ext.${var.hosted_zone_cas_qa.name}"
  allow_overwrite = true
  type            = "A"
  zone_id         = var.hosted_zone_cas_qa.id

  alias {
    name                   = aws_lb.cas_qa_nlb.dns_name
    zone_id                = aws_lb.cas_qa_nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "cas_qa_nlb" {
  name        = "${var.resource_name_prefixes.normal}:NLB:CASQA"
  description = "External NLB for CAS QA"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:NLB:CASQA"
  }
}

resource "aws_security_group_rule" "cas_qa_nlb_ingress" {
  description       = "Allows inbound HTTPS from allowed IPs"
  from_port         = 443
  prefix_list_ids   = [aws_ec2_managed_prefix_list.cas_qa_ingress_safelist.id]
  protocol          = "tcp"
  security_group_id = aws_security_group.cas_qa_nlb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cas_qa_nlb_to_alb" {
  description              = "Allows outward HTTPS from the cas_qa NLB to ALB"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_qa_nlb.id
  source_security_group_id = aws_security_group.cas_qa_lb.id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "cas_qa_alb_from_nlb" {
  description              = "Allows inbound HTTPS to the cas_qa ALB from NLB"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cas_qa_lb.id
  source_security_group_id = aws_security_group.cas_qa_nlb.id
  to_port                  = 443
  type                     = "ingress"
}
