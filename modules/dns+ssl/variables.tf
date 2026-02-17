
# Domain

variable "domain_name" {
  type = string
}

variable "create_hosted_zone" {
  type    = bool
  default = false
}


# ALB Info

variable "external_alb_dns_name" {
  type = string
}

variable "external_alb_zone_id" {
  type = string
}


# Tags

variable "tags" {
  type    = map(string)
  default = {}
}
