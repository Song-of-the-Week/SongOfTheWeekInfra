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

variable "frontend_container_name" {
  type    = string
  default = "frontend"
}

variable "backend_container_name" {
  type    = string
  default = "api"
}

variable "proxy_container_name" {
  type    = string
  default = "nginx"
}

variable "email_user" {
  type    = string
  default = "no-reply"
}