output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_subnets
}

output "cluster_id" {
  description = "The EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The EKS cluster ARN."
  value       = module.eks.cluster_arn
}

# Karpenter specific outputs
output "karpenter_iam_role_arn" {
  description = "The IAM role ARN used by Karpenter."
  value       = module.karpenter.role_arn
}
