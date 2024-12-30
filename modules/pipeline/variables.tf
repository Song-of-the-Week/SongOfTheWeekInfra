variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "repo_path" {
  type    = string
  default = "Song-of-the-Week/sotw-web-app"
}

variable "assume_role_name" {
  type = string
}

variable "build_branch" {
  type    = string
  default = "main"
}