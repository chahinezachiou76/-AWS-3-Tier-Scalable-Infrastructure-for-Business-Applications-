variable "vpc_id" {
  type = string
}

variable "admin_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
