variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "assume_role_name" {
  type = string
}

variable "domain_name" {
  default = "sotw-app.com"
  type    = string
}

variable "acm_cert_id" {
  default = "600396fb-89ba-4790-a6ab-ab60af3be6cc"
  type    = string
}