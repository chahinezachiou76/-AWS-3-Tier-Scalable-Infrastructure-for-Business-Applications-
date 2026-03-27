resource "aws_sns_topic" "billing_alerts" {
  name = "finops-billing-alerts-topic"
}

resource "aws_budgets_budget" "total_monthly_budget" {
  name              = "monthly-total-budget"
  budget_type       = "COST"
  limit_amount      = "50.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 75
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.billing_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["admin@example.com"]
  }
}

resource "aws_budgets_budget" "ec2_specific_budget" {
  name              = "monthly-ec2-usage-budget"
  budget_type       = "COST"
  limit_amount      = "20.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }
}