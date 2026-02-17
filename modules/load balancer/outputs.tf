output "external_alb_arn" {
  value = aws_lb.external_alb.arn
}

output "external_alb_dns_name" {
  value = aws_lb.external_alb.dns_name
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "internal_alb_arn" {
  value = aws_lb.internal_alb.arn
}

output "internal_alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend_tg.arn
}
