variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "public_subnet_1a_arn" {
  type = string
}

variable "public_subnet_1c_arn" {
  type = string
}

variable "public_subnet_1a_id" {
  type = string
}

variable "public_subnet_1c_id" {
  type = string
}

variable "github_settings" {
  type = object({
    connection_arn = string
    app_repository = string
    deploy_branch  = string
  })
}
