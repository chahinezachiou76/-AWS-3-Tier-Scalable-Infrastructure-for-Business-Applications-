# Security Groups

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.main.id

  # Inbound from internet
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Outbound to anywhere (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "alb-sg" })
}

# App / EC2 Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "app-sg" })
}

# Aurora DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "aurora-sg"
  description = "Allow traffic from App SG only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "MySQL from App SG"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "aurora-sg" })
}

# WAF (Web ACL)
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "app-waf"
  scope       = "REGIONAL" # ALB regional
  description = "Web ACL for ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "common-rules"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "waf-metric"
  }

  tags = merge(local.common_tags, { Name = "app-waf" })
}

# WAF association with ALB
resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}