# ============================
# RDS instance
# ============================
resource "aws_db_instance" "rds" {
  engine         = "mysql"
  engine_version = "8.0.32"

  identifier = "${var.environment}-${var.project}-rds"

  username = "admin"
  password = "dummy"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 1000
  storage_type          = "gp2"
  storage_encrypted     = true

  multi_az               = false
  availability_zone      = "ap-northeast-1c"
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  port                   = 3306

  db_name              = "maxi_app_db"
  parameter_group_name = "default.mysql8.0"
  option_group_name    = "default:mysql-8-0"

  backup_window              = "16:04-16:34"
  backup_retention_period    = 1
  maintenance_window         = "tue:13:16-tue:13:46"
  auto_minor_version_upgrade = true

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately     = true
  copy_tags_to_snapshot = true

  tags = {
    Name    = "${var.environment}-${var.project}-rds"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    ignore_changes = [
      identifier,
      password,
      db_subnet_group_name
    ]
  }
}

# ============================
# RDS subnet group
# ============================
resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.environment}-${var.project}-subnet-group"
  description = "maxi_app_subnet_group"
  subnet_ids = [
    var.private_subnet_1a_id,
    var.private_subnet_1c_id
  ]

  tags = {
    Name    = "${var.environment}-${var.project}-subnet-group"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}
