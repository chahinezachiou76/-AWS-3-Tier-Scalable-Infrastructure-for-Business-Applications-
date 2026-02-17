
# External ALB (Public)

resource "aws_lb" "external_alb" {
  name               = "multi-az-external-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.external_alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "multi-az-external-alb"
  })
}


# Frontend Target Group

resource "aws_lb_target_group" "frontend_tg" {
  name     = "multi-az-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "multi-az-frontend-tg"
  })
}


# External ALB Listener

resource "aws_lb_listener" "external_http_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


# Internal ALB (Private)

resource "aws_lb" "internal_alb" {
  name               = "multi-az-internal-alb"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.private_app_subnet_ids

  tags = merge(var.tags, {
    Name = "multi-az-internal-alb"
  })
}

# Backend Target Group

resource "aws_lb_target_group" "backend_tg" {
  name     = "multi-az-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "multi-az-backend-tg"
  })
}


# Internal ALB Listener

resource "aws_lb_listener" "internal_http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
