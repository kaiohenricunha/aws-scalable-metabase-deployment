terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
      configuration_aliases = [kubectl.gavinbunney]
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-west-2"
  alias = "oregon"
}

provider "aws" {
  region = "us-east-1"
  alias = "virginia"
}

provider "kubernetes" {
  host                   = module.eks_fargate_karpenter.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_fargate_karpenter.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_fargate_karpenter.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_fargate_karpenter.cluster_name]
    }
  }
}

provider "kubectl" {
  alias = "gavinbunney"
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_fargate_karpenter.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_fargate_karpenter.cluster_name]
  }
}
