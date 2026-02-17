
# Frontend Launch Template

resource "aws_launch_template" "frontend_lt" {
  name_prefix   = "multi-az-frontend-"
  image_id      = var.frontend_ami_id
  instance_type = var.frontend_instance_type

  vpc_security_group_ids = [var.frontend_sg_id]

  user_data = base64encode(var.frontend_user_data)

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "multi-az-frontend"
      Tier = "frontend"
    })
  }
}


# Backend Launch Template

resource "aws_launch_template" "backend_lt" {
  name_prefix   = "multi-az-backend-"
  image_id      = var.backend_ami_id
  instance_type = var.backend_instance_type

  vpc_security_group_ids = [var.backend_sg_id]

  user_data = base64encode(var.backend_user_data)

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "multi-az-backend"
      Tier = "backend"
    })
  }
}


# Frontend Auto Scaling Group

resource "aws_autoscaling_group" "frontend_asg" {
  name                = "multi-az-frontend-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  desired_capacity    = var.frontend_desired_capacity
  min_size            = var.frontend_min_size
  max_size            = var.frontend_max_size

  target_group_arns = [var.frontend_target_group_arn]

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "multi-az-frontend"
    propagate_at_launch = true
  }
}


# Backend Auto Scaling Group

resource "aws_autoscaling_group" "backend_asg" {
  name                = "multi-az-backend-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  desired_capacity    = var.backend_desired_capacity
  min_size            = var.backend_min_size
  max_size            = var.backend_max_size

  target_group_arns = [var.backend_target_group_arn]

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "multi-az-backend"
    propagate_at_launch = true
  }
}


# Bastion Host

resource "aws_instance" "bastion_host" {
  ami                         = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "multi-az-bastion"
  })
}
