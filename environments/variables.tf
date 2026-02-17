###################################
# AWS
###################################
variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

###################################
# Network
###################################
variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "private_db_subnet_cidrs" {
  type = list(string)
}

###################################
# Security
###################################
variable "admin_cidr_blocks" {
  type = list(string)
}

###################################
# Compute (AMI IDs)
###################################
variable "frontend_ami_id" {
  type = string
}

variable "backend_ami_id" {
  type = string
}

variable "bastion_ami_id" {
  type = string
}

###################################
# Database
###################################
variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type      = string
  sensitive = true
}

###################################
# DNS
###################################
variable "domain_name" {
  type = string
}
