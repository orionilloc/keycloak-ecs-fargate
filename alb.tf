#alb.tf

resource "aws_acm_certificate" "keycloak" {
  domain_name       = "auth.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.keycloak.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = data.aws_route53_zone.existing.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "keycloak" {
  certificate_arn         = aws_acm_certificate.keycloak.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_lb" "keycloak_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_target_group" "keycloak" {
  name        = "${var.project_name}-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab_vpc.id
  target_type = "ip"

  health_check {
    path     = "/health/ready"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.keycloak_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.keycloak.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.keycloak_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
