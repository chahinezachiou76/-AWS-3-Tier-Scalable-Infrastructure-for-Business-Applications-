output "external_alb_sg_id" {
  value = aws_security_group.external_alb_sg.id
}

output "frontend_sg_id" {
  value = aws_security_group.frontend_sg.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb_sg.id
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "database_sg_id" {
  value = aws_security_group.database_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
