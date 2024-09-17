# ============================
# IAM Role
# ============================
resource "aws_iam_role" "codepipeline_role" {
  name               = "AWSCodePipelineServiceRole-ap-northeast-1-maxi_app_pipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/AWSCodePipelineServiceRole-ap-northeast-1-maxi_app_pipeline",
  ]
  path = "/service-role/"
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "maxi_app_codebuild_role"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::${var.aws_account_id}:policy/ecs-task-execution-policy",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildBasePolicy-maxi_app_api_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildBasePolicy-maxi_app_nginx_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildBasePolicy-maxi_app_rails_migration_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildManagedSecretPolicy-maxi_app_api_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildManagedSecretPolicy-maxi_app_nginx_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildManagedSecretPolicy-maxi_app_rails_migration_codebuild-ap-northeast-1",
    "arn:aws:iam::${var.aws_account_id}:policy/service-role/CodeBuildVpcPolicy-maxi_app_rails_migration_codebuild-ap-northeast-1",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
  ]
  max_session_duration = 3600
  path                 = "/service-role/"

  inline_policy {
    name = "CodeBuildEcsRuntaskPolicy"
    policy = jsonencode(
      {
        Statement = [
          {
            Action   = "ecs:RunTask"
            Effect   = "Allow"
            Resource = "arn:aws:ecs:*:${var.aws_account_id}:task-definition/*"
            Sid      = "VisualEditor0"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
  inline_policy {
    name = "EC2DescribePolicy"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "ec2:CreateNetworkInterface",
              "ec2:DescribeDhcpOptions",
              "ec2:DescribeNetworkInterfaces",
              "ec2:DeleteNetworkInterface",
              "ec2:DescribeSubnets",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeVpcs",
            ]
            Effect   = "Allow"
            Resource = "*"
          },
          {
            Action = [
              "ec2:CreateNetworkInterfacePermission",
            ]
            Condition = {
              ArnEquals = {
                "ec2:Subnet" = [
                  var.public_subnet_1a_arn,
                  var.public_subnet_1c_arn,
                ]
              }
              StringEquals = {
                "ec2:AuthorizedService" = "codebuild.amazonaws.com"
              }
            }
            Effect   = "Allow"
            Resource = "arn:aws:ec2:ap-northeast-1:${var.aws_account_id}:network-interface/*"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
  inline_policy {
    name = "policy_for_ssm_get_parameters"
    policy = jsonencode(
      {
        Statement = [
          {
            Action   = "ssm:GetParameters"
            Effect   = "Allow"
            Resource = "arn:aws:ssm:*:${var.aws_account_id}:parameter/*"
            Sid      = "VisualEditor0"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# ============================
# S3 Bucket
# ============================
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-ap-northeast-1-198814721361"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = file("modules/codepipeline/templates/codepipeline_bucket.json")
}

# ============================
# CodeBuld
# ============================
resource "aws_codebuild_project" "api_codebuild" {
  name               = "maxi_app_api_codebuild"
  badge_enabled      = false
  build_timeout      = 60
  encryption_key     = "arn:aws:kms:ap-northeast-1:${var.aws_account_id}:alias/aws/s3"
  project_visibility = "PRIVATE"
  queued_timeout     = 480
  service_role       = aws_iam_role.codebuild_role.arn

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "API_REPOSITORY"
      type  = "PLAINTEXT"
      value = "maxi_app_api"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = "ap-northeast-1"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = var.aws_account_id
    }
    environment_variable {
      name  = "DOCKERHUB_USER"
      type  = "PARAMETER_STORE"
      value = "/docker_hub/user_name"
    }
    environment_variable {
      name  = "DOCKERHUB_PASS"
      type  = "PARAMETER_STORE"
      value = "/docker_hub/password"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = ".codebuild/api_buildspec.yml"
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/kwansai724/maxi_app.git"
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}

resource "aws_codebuild_project" "nginx_codebuild" {
  name               = "maxi_app_nginx_codebuild"
  badge_enabled      = false
  build_timeout      = 60
  encryption_key     = "arn:aws:kms:ap-northeast-1:${var.aws_account_id}:alias/aws/s3"
  project_visibility = "PRIVATE"
  queued_timeout     = 480
  service_role       = aws_iam_role.codebuild_role.arn

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "NGINX_REPOSITORY"
      type  = "PLAINTEXT"
      value = "maxi_app_nginx"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = "ap-northeast-1"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = var.aws_account_id
    }
    environment_variable {
      name  = "DOCKERHUB_USER"
      type  = "PARAMETER_STORE"
      value = "/docker_hub/user_name"
    }
    environment_variable {
      name  = "DOCKERHUB_PASS"
      type  = "PARAMETER_STORE"
      value = "/docker_hub/password"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = ".codebuild/nginx_buildspec.yml"
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/kwansai724/maxi_app.git"
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}

resource "aws_codebuild_project" "rails_migration_codebuild" {
  name               = "maxi_app_rails_migration_codebuild"
  badge_enabled      = false
  build_timeout      = 60
  encryption_key     = "arn:aws:kms:ap-northeast-1:${var.aws_account_id}:alias/aws/s3"
  project_visibility = "PRIVATE"
  queued_timeout     = 480
  service_role       = aws_iam_role.codebuild_role.arn

  artifacts {
    encryption_disabled    = false
    name                   = "maxi_app_rails_migration_codebuild"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = "ap-northeast-1"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = var.aws_account_id
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      type  = "PLAINTEXT"
      value = "maxi_app_cluster"
    }
    environment_variable {
      name  = "TASK_NAME"
      type  = "PLAINTEXT"
      value = "maxi_app_migration_task"
    }
    environment_variable {
      name  = "SUBNET_ID_01"
      type  = "PLAINTEXT"
      value = var.public_subnet_1c_id
    }
    environment_variable {
      name  = "SUBNET_ID_02"
      type  = "PLAINTEXT"
      value = var.public_subnet_1a_id
    }
    environment_variable {
      name  = "SECURITY_GROUP_ID"
      type  = "PLAINTEXT"
      value = "sg-002d7140f9551bd5e"
    }
    environment_variable {
      name  = "API_REPOSITORY"
      type  = "PLAINTEXT"
      value = "maxi_app_api"
    }
    environment_variable {
      name  = "RAILS_ENV"
      type  = "PLAINTEXT"
      value = "production"
    }
    environment_variable {
      name  = "DB_USERNAME"
      type  = "PARAMETER_STORE"
      value = "/maxi_app/db_username"
    }
    environment_variable {
      name  = "DB_PASSWORD"
      type  = "PARAMETER_STORE"
      value = "/maxi_app/db_password"
    }
    environment_variable {
      name  = "DB_HOST"
      type  = "PARAMETER_STORE"
      value = "/maxi_app/db_host"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = ".codebuild/migration_buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

# ============================
# Codepipeline
# ============================
resource "aws_codepipeline" "codepipeline" {
  name     = "maxi_app_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name      = "Source"
      category  = "Source"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"
      configuration = {
        "BranchName"           = var.github_settings.deploy_branch
        "ConnectionArn"        = var.github_settings.connection_arn
        "FullRepositoryId"     = var.github_settings.app_repository
        "OutputArtifactFormat" = "CODE_ZIP"
      }
      input_artifacts = []
      output_artifacts = [
        "SourceArtifact",
      ]
    }
  }
  stage {
    name = "Build"

    action {
      name      = "ApiBuild"
      category  = "Test"
      owner     = "AWS"
      provider  = "CodeBuild"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "API_REPOSITORY"
              type  = "PLAINTEXT"
              value = "maxi_app_api"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.api_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "api_build_output",
      ]
    }
    action {
      name      = "NginxBuild"
      category  = "Test"
      owner     = "AWS"
      provider  = "CodeBuild"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "NGINX_REPOSITORY"
              type  = "PLAINTEXT"
              value = "maxi_app_nginx"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.nginx_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "nginx_build_output",
      ]
    }
  }
  stage {
    name = "Approval"

    action {
      category  = "Approval"
      name      = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Test"
      configuration = {
        "ProjectName" = aws_codebuild_project.rails_migration_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name      = "RailsMigration"
      owner     = "AWS"
      provider  = "CodeBuild"
      region    = "ap-northeast-1"
      run_order = 1
      version   = "1"
    }
    action {
      name      = "Deploy"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "CodeDeployToECS"
      region    = "ap-northeast-1"
      run_order = 2
      version   = "1"
      configuration = {
        "AppSpecTemplateArtifact"        = "SourceArtifact"
        "AppSpecTemplatePath"            = ".codebuild/appspec.yaml"
        "ApplicationName"                = "AppECS-maxi_app_cluster-maxi-app-service"
        "DeploymentGroupName"            = "DgpECS-maxi_app_cluster-maxi-app-service"
        "Image1ArtifactName"             = "api_build_output"
        "Image1ContainerName"            = "API_IMAGE_NAME"
        "Image2ArtifactName"             = "nginx_build_output"
        "Image2ContainerName"            = "NGINX_IMAGE_NAME"
        "TaskDefinitionTemplateArtifact" = "SourceArtifact"
        "TaskDefinitionTemplatePath"     = ".codebuild/taskdef.json"
      }
      input_artifacts = [
        "api_build_output",
        "nginx_build_output",
        "SourceArtifact",
      ]
    }
  }
}