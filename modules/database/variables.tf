
# Networking

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "database_sg_id" {
  type = string
}


# Aurora Config

variable "engine" {
  type    = string
  default = "aurora-mysql"
}

variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.04.0"
}

variable "instance_class" {
  type = string
}

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


# Tags

variable "tags" {
  type    = map(string)
  default = {}
}
