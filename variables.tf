variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "github_settings" {
  default = {
    connection_arn = "arn:aws:codestar-connections:ap-northeast-1:924338382227:connection/0412a410-aa0f-4e2e-ac8d-2d025106d093"
    app_repository = "kwansai724/maxi_app"
    deploy_branch  = "develop"
  }
}
