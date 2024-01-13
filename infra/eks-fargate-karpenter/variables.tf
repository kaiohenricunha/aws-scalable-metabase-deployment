variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "fargate_profiles" {
  description = "Fargate profile configurations"
  type        = map(any)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "List of IDs of intra subnets"
  type        = list(string)
}
