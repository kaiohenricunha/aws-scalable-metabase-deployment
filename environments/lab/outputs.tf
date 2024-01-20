output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.lab_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.lab_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.lab_vpc.public_subnets
}

output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = module.lab_vpc.default_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "The eks_fargate_karpenter cluster primary security group ID."
  value       = module.eks_fargate_karpenter.cluster_primary_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "The eks_fargate_karpenter cluster certificate authority data."
  value       = module.eks_fargate_karpenter.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The eks_fargate_karpenter cluster endpoint."
  value       = module.eks_fargate_karpenter.cluster_endpoint
}

output "cluster_id" {
  description = "The eks_fargate_karpenter cluster ID."
  value       = module.eks_fargate_karpenter.cluster_id
}

output "cluster_name" {
  description = "The eks_fargate_karpenter cluster name."
  value       = module.eks_fargate_karpenter.cluster_name
}

output "cluster_version" {
  description = "The eks_fargate_karpenter cluster Kubernetes version."
  value       = module.eks_fargate_karpenter.cluster_version
}

output "cluster_oidc_issuer_url" {
  description = "The eks_fargate_karpenter cluster OpenID Connect issuer URL."
  value       = module.eks_fargate_karpenter.cluster_oidc_issuer_url
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks_fargate_karpenter.oidc_provider
}
