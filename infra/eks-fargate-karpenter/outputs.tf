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
