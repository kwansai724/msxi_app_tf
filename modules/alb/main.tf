# ============================
# S3 Bucket
# ============================
resource "aws_s3_bucket" "alb-access-logs" {
  bucket = "alb-access-logs-for-kwansai724"
}

resource "aws_s3_bucket_public_access_block" "alb-access-logs" {
  bucket                  = aws_s3_bucket.alb-access-logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb-access-logs" {
  bucket = aws_s3_bucket.alb-access-logs.id
  policy = file("modules/alb/templates/alb-access-logs.json")
}

# ============================
# ALB
# ============================
resource "aws_lb" "alb" {
  name               = "${var.environment}-${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    var.alb_sg_id
  ]
  subnets = [
    var.public_subnet_1a_id,
    var.public_subnet_1c_id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb-access-logs.bucket
    enabled = false
    prefix  = "maxi-app-alb-logs"
  }

  tags = {
    Name    = "${var.environment}-${var.project}-alb"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    order            = 1
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group2.arn
  }
}

# ============================
# target group
# ============================
resource "aws_lb_target_group" "target_group" {
  name                              = "${var.environment}-${var.project}-target-group"
  port                              = 80
  protocol                          = "HTTP"
  vpc_id                            = var.vpc_id
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  target_type                       = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 300
    matcher             = "200"
    path                = "/api/health_check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 60
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  tags = {
    Name    = "${var.environment}-${var.project}-target-group"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "aws_lb_target_group" "target_group2" {
  name                              = "${var.environment}-${var.project}-target-group2"
  port                              = 80
  protocol                          = "HTTP"
  vpc_id                            = var.vpc_id
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  target_type                       = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 300
    matcher             = "200"
    path                = "/api/health_check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 60
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  tags = {
    Name    = "${var.environment}-${var.project}-target-group2"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}
