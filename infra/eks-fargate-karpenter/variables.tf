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
