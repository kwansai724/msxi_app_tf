# ============================
# Parameter Store
# ============================
resource "aws_ssm_parameter" "db_host" {
  name  = "/maxi_app/db_host"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/maxi_app/db_name"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/maxi_app/db_password"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/maxi_app/db_username"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "master_key" {
  name  = "/maxi_app/master_key"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "my_email" {
  name  = "/maxi_app/my_email"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "my_password" {
  name  = "/maxi_app/my_password"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "secret_key_base" {
  name  = "/maxi_app/secret_key_base"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "docker_hub_password" {
  name  = "/docker_hub/password"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "docker_hub_user_name" {
  name  = "/docker_hub/user_name"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
