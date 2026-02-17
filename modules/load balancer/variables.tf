variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "external_alb_sg_id" {
  type = string
}

variable "internal_alb_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
