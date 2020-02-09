resource "aws_lb" "redirects" {
  name               = "rlafferty-redirect-alb"
  internal           = false
  load_balancer_type = "application"

  subnets            = aws_subnet.subnet.*.id
  security_groups    = [aws_security_group.alb-redirect.id]

  tags = {
    Name = "rlafferty-redirect-alb"
    owner = "rlafferty"
  }
}

resource "aws_security_group" "alb-redirect" {
  name        = "rlafferty-alb-redirect"
  description = "Allow inbound http(s) to rlaffery-redirect-alb"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    owner = "rlafferty"
    Name  = "rlafferty-alb-redirect"
  }
}

resource "aws_security_group_rule" "ingress-80" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-redirect.id
}

resource "aws_security_group_rule" "ingress-443" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-redirect.id
}

resource "aws_lb_listener" "redirect-80" {
  load_balancer_arn = aws_lb.redirects.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "alb-redirect" {
  name = "alb-redirect.${var.dns_zone}"
  zone_id = data.aws_route53_zone.rlafferty.id
  type = "A"

  alias {
    name    = aws_lb.redirects.dns_name
    zone_id = aws_lb.redirects.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "alb-redirect" {
  domain_name       = "alb-redirect.${var.dns_zone}"
  validation_method = "DNS"

  tags = {
    owner = "rlafferty"
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.alb-redirect.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.alb-redirect.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.rlafferty.id
  records = [aws_acm_certificate.alb-redirect.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.alb-redirect.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_lb_listener" "redirect-443" {
  load_balancer_arn = aws_lb.redirects.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.alb-redirect.arn

  default_action {
    type = "redirect"

    redirect {
      host        = "www.pagerduty.com"
      port        = "443"
      path        = "/"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

### below this are the customizations!

# redirect dutonium.rlafferty.pd-development.com
resource "aws_acm_certificate" "dutonium" {
  domain_name       = "dutonium.${var.dns_zone}"
  validation_method = "DNS"

  tags = {
    owner = "rlafferty"
  }
}

resource "aws_route53_record" "dutonium_validation" {
  name    = aws_acm_certificate.dutonium.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.dutonium.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.rlafferty.id
  records = [aws_acm_certificate.dutonium.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "dutonium" {
  certificate_arn         = aws_acm_certificate.dutonium.arn
  validation_record_fqdns = [aws_route53_record.dutonium_validation.fqdn]
}

resource "aws_lb_listener_certificate" "dutonium" {
  listener_arn    = aws_lb_listener.redirect-443.arn
  certificate_arn = aws_acm_certificate.dutonium.arn
}

resource "aws_route53_record" "dutonium" {
  name = "dutonium.${var.dns_zone}"
  zone_id = data.aws_route53_zone.rlafferty.id
  type = "A"

  alias {
    name    = aws_lb.redirects.dns_name
    zone_id = aws_lb.redirects.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_rule" "dutonium" {
  listener_arn = aws_lb_listener.redirect-443.arn

  condition {
    host_header {
      values = ["dutonium.${var.dns_zone}"]
    }
  }

  action {
    type = "redirect"

    redirect {
      host        = "dutonium.pagerduty.com"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
