data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name   = "metabaselab"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  oidc_id = regex("https://oidc.eks.${local.region}.amazonaws.com/id/(.*)", module.eks_fargate_karpenter.cluster_oidc_issuer_url)[0]

  tags = {
    Name       = local.name
    Repository = "https://github.com/kaiohenricunha/aws-scalable-metabase-deployment"
  }
}

################################################################################
# VPC
################################################################################
module "lab_vpc" {
  source = "../../infra/vpc"

  name            = local.name
  vpc_cidr        = local.vpc_cidr
  azs             = local.azs
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.128.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19", "10.0.160.0/19"]
  intra_subnets   = ["10.0.192.0/19", "10.0.224.0/19"]

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

  vpc_security_group_ids = [module.security_group.security_group_id, module.eks_fargate_karpenter.cluster_primary_security_group_id]
  subnet_ids             = module.lab_vpc.private_subnets

  tags = local.tags
}

################################################################################
# Security Group for RDS
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = local.name
  vpc_id = module.lab_vpc.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      source_security_group_id = module.eks_fargate_karpenter.cluster_primary_security_group_id
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL access from within VPC"
    },
  ]

  tags = local.tags
}

################################################################################
# AWS Load Balancer Controller
################################################################################
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.iam_policy.body
}

resource "aws_iam_role" "load_balancer_controller_role" {
  name = "eks-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${local.region}.amazonaws.com/id/${local.oidc_id}"
        },
        Condition = {
          StringEquals = {
            "${module.eks_fargate_karpenter.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy_attach" {
  role       = aws_iam_role.load_balancer_controller_role.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "kubernetes_service_account" "load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load_balancer_controller_role.arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = local.name
  }

  set {
    name  = "region"
    value = local.region
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "vpcId"
    value = module.lab_vpc.vpc_id
  }

  depends_on = [aws_iam_role.load_balancer_controller_role, kubernetes_service_account.load_balancer_controller]
}
