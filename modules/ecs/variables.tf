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

variable "email_user_from_name" {
  type    = string
  default = "Song of the Week"
}


variable "registration_verification_endpoint" {
  type    = string
  default = "auth/verify/"
}

variable "email_change_verification_endpoint" {
  type    = string
  default = "user/email/verify/"
}

variable "password_reset_verification_endpoint" {
  type    = string
  default = "password-reset/"
}

variable "send_registration_emails" {
  type    = string
  default = "true"
}

variable "app_off_time" {
  type        = string
  default     = "30 03"
  description = "<MM> <HH> in UTC"
}

variable "app_on_time" {
  type        = string
  default     = "30 15"
  description = "<MM> <HH> in UTC"
}

variable "minimum_ec2_instances" {
  type    = number
  default = 1
}

variable "maximum_ec2_instances" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "t3a.small"
}