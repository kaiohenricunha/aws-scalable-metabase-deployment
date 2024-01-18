output "this_vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "security_group_id" {
  description = "The ID of the security group created for RDS"
  value       = module.security_group.security_group_id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_fargate_karpenter.cluster_name
}
