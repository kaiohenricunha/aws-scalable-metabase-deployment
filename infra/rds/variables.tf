variable "db_name" {
  description = "The name of the database to create in the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The username for the database administrator"
  type        = string
}

variable "db_password" {
  description = "The password for the database administrator"
  type        = string
}

variable "db_port" {
  description = "The port on which the database accepts connections"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs to associate with the RDS instance"
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to associate with the RDS instance"
  type        = list(string)
}
