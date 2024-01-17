variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
}

variable "db_port" {
  description = "The port for the database"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs"
  type        = list(string)
}

variable "availability_zone" {
  description = "The availability zone for the database"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the database subnet group"
  type        = string
}
