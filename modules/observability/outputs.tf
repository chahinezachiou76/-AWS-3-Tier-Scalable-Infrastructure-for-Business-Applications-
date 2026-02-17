output "app_log_group_name" {
  value = aws_cloudwatch_log_group.app_logs.name
}

output "system_log_group_name" {
  value = aws_cloudwatch_log_group.system_logs.name
}

output "cloudtrail_name" {
  value = aws_cloudtrail.multi_az_trail.name
}
