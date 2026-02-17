###################################
# CloudWatch Log Group (Application)
###################################
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/multi-az/application"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "multi-az-app-logs"
  })
}

###################################
# CloudWatch Log Group (System)
###################################
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/multi-az/system"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "multi-az-system-logs"
  })
}

###################################
# CloudWatch Alarm - High CPU Frontend
###################################
resource "aws_cloudwatch_metric_alarm" "frontend_high_cpu" {
  alarm_name          = "multi-az-frontend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.frontend_asg_name
  }

  alarm_description = "Frontend CPU usage too high"
}

###################################
# CloudWatch Alarm - High CPU Backend
###################################
resource "aws_cloudwatch_metric_alarm" "backend_high_cpu" {
  alarm_name          = "multi-az-backend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.backend_asg_name
  }

  alarm_description = "Backend CPU usage too high"
}

###################################
# CloudTrail
###################################
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "multi-az-cloudtrail-logs-${var.account_id}"

  tags = merge(var.tags, {
    Name = "multi-az-cloudtrail-bucket"
  })
}

resource "aws_cloudtrail" "multi_az_trail" {
  name                          = "multi-az-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}
