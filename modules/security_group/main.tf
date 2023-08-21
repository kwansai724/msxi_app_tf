# ============================
# Security Group
# ============================
# ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-${var.project}-alb-sg"
  description = "maxi_app_alb_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.environment}-${var.project}-alb-sg"
    Project = var.project
    Env     = var.environment
  }

  ingress {
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

# RDS security group
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-${var.project}-rds-sg"
  description = "maxi_app_rds_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.environment}-${var.project}-rds-sg"
    Project = var.project
    Env     = var.environment
  }

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.alb_sg.id,
      aws_security_group.jump_server_sg.id,
      aws_security_group.code_build_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  lifecycle {
    ignore_changes = [
      name,
      description
    ]
  }
}

# Jump Server security group
resource "aws_security_group" "jump_server_sg" {
  name        = "${var.environment}-${var.project}-jump-server-sg"
  description = "maxi_app_jump_server_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.environment}-${var.project}-jump-server-sg"
    Project = var.project
    Env     = var.environment
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

# CodeBuild security group
resource "aws_security_group" "code_build_sg" {
  name        = "${var.environment}-${var.project}-code-build-sg"
  description = "maxi_app_code_build_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.environment}-${var.project}-code-build-sg"
    Project = var.project
    Env     = var.environment
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}
