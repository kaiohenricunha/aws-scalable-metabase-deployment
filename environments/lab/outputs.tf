output "lab_vpc_id" {
  description = "The ID of the lab_vpc"
  value       = module.lab_vpc.lab_vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.lab_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.lab_vpc.public_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.lab_vpc.intra_subnets
}

output "cluster_id" {
  description = "The eks_fargate_karpenter cluster ID."
  value       = module.eks_fargate_karpenter.cluster_id
}

output "cluster_arn" {
  description = "The eks_fargate_karpenter cluster ARN."
  value       = module.eks_fargate_karpenter.cluster_arn
}

# Karpenter specific outputs
output "karpenter_iam_role_arn" {
  description = "The IAM role ARN used by Karpenter."
  value       = module.eks_fargate_karpenter.role_arn
}
