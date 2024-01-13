output "cluster_id" {
  description = "The eks_fargate_karpenter cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The eks_fargate_karpenter cluster ARN."
  value       = module.eks.cluster_arn
}

# Karpenter specific outputs
output "karpenter_iam_role_arn" {
  description = "The IAM role ARN used by Karpenter."
  value       = module.karpenter.role_arn
}
