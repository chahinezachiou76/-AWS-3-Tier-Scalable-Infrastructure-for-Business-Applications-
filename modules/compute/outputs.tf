output "frontend_asg_name" {
  value = aws_autoscaling_group.frontend_asg.name
}

output "backend_asg_name" {
  value = aws_autoscaling_group.backend_asg.name
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
