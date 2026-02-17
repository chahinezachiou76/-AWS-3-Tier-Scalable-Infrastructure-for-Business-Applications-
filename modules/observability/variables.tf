###################################
# ASGs
###################################
variable "frontend_asg_name" {
  type = string
}

variable "backend_asg_name" {
  type = string
}

###################################
# CloudTrail
###################################
variable "account_id" {
  type = string
}

###################################
# Logs
###################################
variable "log_retention_days" {
  type    = number
  default = 30
}

###################################
# Tags
###################################
variable "tags" {
  type    = map(string)
  default = {}
}
