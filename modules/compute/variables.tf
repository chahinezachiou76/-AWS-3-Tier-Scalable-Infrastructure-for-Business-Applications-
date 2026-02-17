
# Subnets & Target Groups

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "frontend_target_group_arn" {
  type = string
}

variable "backend_target_group_arn" {
  type = string
}


# Security Groups

variable "frontend_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "bastion_sg_id" {
  type = string
}


# AMIs & Instance Types

variable "frontend_ami_id" {
  type = string
}

variable "backend_ami_id" {
  type = string
}

variable "bastion_ami_id" {
  type = string
}

variable "frontend_instance_type" {
  type = string
}

variable "backend_instance_type" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}


# User Data

variable "frontend_user_data" {
  type    = string
  default = ""
}

variable "backend_user_data" {
  type    = string
  default = ""
}


# ASG Sizes

variable "frontend_desired_capacity" { type = number }
variable "frontend_min_size"         { type = number }
variable "frontend_max_size"         { type = number }

variable "backend_desired_capacity" { type = number }
variable "backend_min_size"         { type = number }
variable "backend_max_size"         { type = number }


# Tags

variable "tags" {
  type    = map(string)
  default = {}
}
