# ============================
# ECS Cluster
# ============================
resource "aws_ecs_cluster" "cluster" {
  name = "maxi_app_cluster"

  tags = {
    "Name" = "maxi_app_cluster"
  }
  tags_all = {
    "Name" = "maxi_app_cluster"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:ap-northeast-1:${var.aws_account_id}:namespace/ns-mkaahryacctd44vw"
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
}

# ============================
# ECS Task Definition
# ============================
resource "aws_ecs_task_definition" "ecs_task" {
  family = "maxi_app_task"
  container_definitions = templatefile(
    "modules/ecs/tamplates/ecs_task_definition.json",
    {
      aws_account_id = var.aws_account_id
    }
  )

  cpu          = "256"
  memory       = "512"
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  volume {
    name = "public"
  }
  volume {
    name = "tmp"
  }
}

# ============================
# ECS Service
# ============================
resource "aws_ecs_service" "app_service" {
  name            = "maxi-app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = "${aws_ecs_task_definition.ecs_task.family}:${aws_ecs_task_definition.ecs_task.revision}"
  iam_role        = "${aws_iam_role.ecs_service_role.path}${aws_iam_role.ecs_service_role.name}"
  launch_type     = "FARGATE"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = false
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  platform_version                   = "1.4.0"
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  tags                               = {}
  tags_all                           = {}
  triggers                           = {}

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    container_name   = "maxi_app_nginx"
    container_port   = 80
    target_group_arn = var.target_group2_arn
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [var.alb_sg_id]
    subnets = [
      var.public_subnet_1a_id,
      var.public_subnet_1c_id
    ]
  }
}

# ============================
# IAM Role
# ============================
resource "aws_iam_role" "task_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  version = "2008-10-17"
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name                  = "AWSServiceRoleForECS"
  assume_role_policy    = data.aws_iam_policy_document.ecs_service_assume_role.json
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy",
  ]
  max_session_duration = 3600
  path                 = "/aws-service-role/ecs.amazonaws.com/"
}

data "aws_iam_policy_document" "ecs_service_assume_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

# ============================
# ECR
# ============================
resource "aws_ecr_repository" "api" {
  name                 = "maxi_app_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "nginx" {
  name                 = "maxi_app_nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
