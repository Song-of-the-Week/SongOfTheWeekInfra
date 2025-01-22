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

variable "invite_token_expire_minutes" {
  type    = string
  default = "10080"
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
  default = 2
}

variable "maximum_ec2_instances" {
  type    = number
  default = 3
}

variable "desired_ec2_instances" {
  type    = number
  default = 2
}


variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_on_demand_ec2_instances" {
  type    = string
  default = 0
}

variable "desired_count_sotw_ecs_tasks" {
  type    = string
  default = 2
}

variable "use_spot_instances" {
  type        = bool
  default     = false
  description = "Turn off when account is in the first 12 months, otherwise turn on."
}

variable "on_demand_percentage_above_base_capacity" {
  type        = string
  default     = 50
  description = "The percentage of instances for the SOTW app that should be on-demand. Only applies when using use_spot_instances is true."
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 50
}

variable "deployment_maximum_percent" {
  type    = number
  default = 100
}