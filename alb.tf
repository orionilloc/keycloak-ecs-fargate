#alb.tf

resource "aws_acm_certificate" "keycloak" {
  domain_name       = var.domain_name
  validation_method = "DNS"
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

resource "aws_lb" "keycloak" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_target_group" "keycloak" {
  name        = ???
  port        = ???  # what port does the ECS task listen on?
  protocol    = ???  # HTTP or HTTPS — where does TLS actually terminate?
  vpc_id      = ???
  target_type = ???  # this matters for Fargate specifically — do you know which value?

  health_check {
    path     = ???  # you already have this one in your notes
    protocol = ???
    matcher  = ???
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = ???
  port              = ???
  protocol          = ???
  ssl_policy        = ???  # AWS has a recommended current one — do you know it or want to look it up?
  certificate_arn   = ???  # depends on validation completing — which resource do you reference?

  default_action {
    type             = ???
    target_group_arn = ???
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = ???
  port              = ???
  protocol          = ???

  default_action {
    type = ???  # not "forward" — what's the redirect action type?
    redirect {
      port        = ???
      protocol    = ???
      status_code = ???  # permanent or temporary redirect?
    }
  }
}
