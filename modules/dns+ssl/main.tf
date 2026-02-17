
# Route53 Hosted Zone (optional)

resource "aws_route53_zone" "hosted_zone" {
  count = var.create_hosted_zone ? 1 : 0

  name = var.domain_name

  tags = merge(var.tags, {
    Name = "multi-az-hosted-zone"
  })
}


# Resolve Zone ID

data "aws_route53_zone" "existing_zone" {
  count        = var.create_hosted_zone ? 0 : 1
  name         = var.domain_name
  private_zone = false
}

locals {
  zone_id = var.create_hosted_zone ?
    aws_route53_zone.hosted_zone[0].zone_id :
    data.aws_route53_zone.existing_zone[0].zone_id
}


# ACM Certificate

resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = merge(var.tags, {
    Name = "multi-az-ssl-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}


# Certificate Validation Records

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      record = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "ssl_validation" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# DNS Record → External ALB

resource "aws_route53_record" "alb_dns_record" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.external_alb_dns_name
    zone_id                = var.external_alb_zone_id
    evaluate_target_health = true
  }
}
