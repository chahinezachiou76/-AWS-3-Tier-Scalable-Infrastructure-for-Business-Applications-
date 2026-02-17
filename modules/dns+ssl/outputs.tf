output "certificate_arn" {
  value = aws_acm_certificate.ssl_cert.arn
}

output "zone_id" {
  value = local.zone_id
}

output "domain_name" {
  value = var.domain_name
}
