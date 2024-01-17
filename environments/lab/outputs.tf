output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.lab_vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.lab_vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.lab_vpc.public_subnets
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.lab_vpc.database_subnets
}

output "intra_subnet_ids" {
  description = "List of IDs of intra subnets"
  value       = module.lab_vpc.intra_subnets
}

output "security_group_id" {
  description = "The ID of the security group created for RDS"
  value       = module.security_group.security_group_id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = local.name
}
