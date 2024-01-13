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
  }
}

################################################################################
# EKS on Fargate and Karpenter
################################################################################

module "eks_fargate_karpenter" {
  source = "../../infra/eks-fargate-karpenter"

  cluster_name             = "metabase-lab"
  cluster_version          = "1.28"

  providers = {
    kubectl.gavinbunney = kubectl.gavinbunney
    aws.virginia         = aws.virginia
    region               = aws.virginia
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
