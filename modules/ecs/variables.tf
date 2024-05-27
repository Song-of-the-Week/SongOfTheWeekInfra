variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "assume_role_name" {
  type = string
}

variable "update_default_version" {
  type    = bool
  default = true
}