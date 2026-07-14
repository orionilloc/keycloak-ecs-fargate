#dns.tf

data "aws_route53_zone" "existing" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "auth_subdomain" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "auth.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.keycloak_alb.dns_name
    zone_id                = aws_lb.keycloak_alb.zone_id
    evaluate_target_health = true
  }
}
