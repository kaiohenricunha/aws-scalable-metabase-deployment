variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
}

variable "cluster_addons" {
  description = "List of cluster addons"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs where to place EKS control plane resources"
  type        = list(string)
}

variable "create_cluster_security_group" {
  description = "Whether to create dedicated security group for EKS cluster"
  type        = bool
}

variable "create_node_security_group" {
  description = "Whether to create dedicated security group for EKS nodes"
  type        = bool
}

variable "manage_aws_auth_configmap" {
  description = "Whether to manage aws-auth configmap"
  type        = bool
}

