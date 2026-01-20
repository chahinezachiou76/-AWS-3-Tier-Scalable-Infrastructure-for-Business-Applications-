# Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, { Name = "app-alb" })
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, { Name = "app-tg" })
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Launch Template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  security_group_names = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Terraform!" > /var/www/html/index.html
              EOF

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "app-ec2" })
  }
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = aws_subnet.private_app[*].id
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  health_check_type          = "ELB"
  health_check_grace_period  = 60
  force_delete               = true

  tags = [
    {
      key                 = "Name"
      value               = "app-asg"
      propagate_at_launch = true
    }
  ]
}

# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}