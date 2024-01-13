variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}
