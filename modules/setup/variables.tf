variable "assume_role_name" {
  description = "Role to assume for AWS API calls"
  default = "terragrunt"
}

variable "account_id" {
  type = string
}