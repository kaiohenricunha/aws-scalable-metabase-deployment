output "cluster_id" {
  description = "The eks_fargate_karpenter cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The eks_fargate_karpenter cluster ARN."
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "The eks_fargate_karpenter cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The eks_fargate_karpenter cluster certificate authority data."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The eks_fargate_karpenter cluster name."
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "The eks_fargate_karpenter cluster Kubernetes version."
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
