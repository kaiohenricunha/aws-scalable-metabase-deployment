################################################################################
# VPC
################################################################################
module "lab_vpc" {
  source  = "../../infra/vpc"

  name    = "lab-vpc"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "lab"
    GithubRepo = "aws-scalable-metabase-deployment"
    GithubOrg  = "kaiohenricunha"
    "karpenter.sh/discovery": "metabase-lab"
  }
}

################################################################################
# EKS on Fargate and Karpenter
################################################################################

module "eks_fargate_karpenter" {
  source = "../../infra/eks-fargate-karpenter"

  cluster_name             = "metabase-lab"
  cluster_version          = "1.28"
  vpc_id                   = module.lab_vpc.vpc_id
  subnet_ids               = module.lab_vpc.private_subnets
  control_plane_subnet_ids = module.lab_vpc.intra_subnets

  providers = {
    kubectl.gavinbunney = kubectl.gavinbunney
    aws.virginia         = aws.virginia
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
