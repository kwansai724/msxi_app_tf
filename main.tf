# ============================
# Terraform Configuration
# ============================
terraform {
  required_version = "=1.5.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
  backend "s3" {
    bucket  = "maxi-app-tf-bucket"
    key     = "dev-maxi-app-tf.tfstate"
    region  = "ap-northeast-1"
    profile = "kwansai724_iam_user"
  }
}

# ============================
# Provider
# ============================
provider "aws" {
  profile = "kwansai724_iam_user"
  region  = "ap-northeast-1"
}

# ============================
# Module
# ============================
module "network" {
  source      = "./modules/network"
  project     = var.project
  environment = var.environment
}

module "sg" {
  source      = "./modules/security_group"
  vpc_id      = module.network.vpc_id
  project     = var.project
  environment = var.environment
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.network.vpc_id
  alb_sg_id           = module.sg.alb_sg_id
  public_subnet_1a_id = module.network.public_subnet_1a_id
  public_subnet_1c_id = module.network.public_subnet_1c_id
  project             = var.project
  environment         = var.environment
}

module "rds" {
  source               = "./modules/rds"
  vpc_id               = module.network.vpc_id
  private_subnet_1a_id = module.network.private_subnet_1a_id
  private_subnet_1c_id = module.network.private_subnet_1c_id
  rds_sg_id            = module.sg.rds_sg_id
  project              = var.project
  environment          = var.environment
}

module "parameter_store" {
  source = "./modules/parameter_store"
}
