variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}
