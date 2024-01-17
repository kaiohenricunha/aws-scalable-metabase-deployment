data "aws_availability_zones" "available" {}

locals {
  name   = "metabase-lab"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/kaiohenricunha/aws-scalable-metabase-deployment"
  }
}

################################################################################
# VPC
################################################################################
module "lab_vpc" {
  source = "../../infra/vpc"

  name     = local.name
  vpc_cidr = local.vpc_cidr

  tags = local.tags
}

################################################################################
# EKS on Fargate and Karpenter
################################################################################
module "eks_fargate_karpenter" {
  source = "../../infra/eks-fargate-karpenter"

  cluster_name             = local.name
  cluster_version          = "1.28"
  vpc_id                   = module.lab_vpc.vpc_id
  subnet_ids               = module.lab_vpc.private_subnets
  control_plane_subnet_ids = module.lab_vpc.intra_subnets

  providers = {
    kubectl.gavinbunney = kubectl.gavinbunney
    aws.virginia        = aws.virginia
  }

  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
    metabase = {
      selectors = [
        { namespace = "metabase" }
      ]
    }
  }
}

################################################################################
# RDS
################################################################################

module "lab_rds" {
  source = "../../infra/rds"

  db_name     = local.name
  db_username = local.name
  db_port     = 3306
  db_password = var.db_password

  vpc_security_group_ids = [module.eks_fargate_karpenter.cluster_primary_security_group_id]
  subnet_ids             = module.lab_vpc.intra_subnets
  availability_zone      = local.azs[0]
}

################################################################################
# Security Group for RDS
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}
