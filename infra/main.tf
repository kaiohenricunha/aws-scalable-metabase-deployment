terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "kaio-lab-terraform-state"
    key    = "state/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
    kms_key_id = "alias/terraform-bucket-key"
  }
}

# KMS Key for S3 Bucket Encryption
resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}

resource "aws_s3_bucket" "terraform-state" {
 bucket = "kaio-lab-terraform-state"

 versioning {
   enabled = true
 }

 server_side_encryption_configuration {
   rule {
     apply_server_side_encryption_by_default {
       kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
       sse_algorithm     = "aws:kms"
     }
   }
 }
}

resource "aws_s3_bucket_public_access_block" "block" {
 bucket = aws_s3_bucket.terraform-state.id

 block_public_acls       = true
 block_public_policy     = true
 ignore_public_acls      = true
 restrict_public_buckets = true
}


module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr_block             = "10.0.0.0/16"
  vpc_name                   = "lab-vpc"
  availability_zones         = ["us-west-2a", "us-west-2b"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidr_blocks  = ["10.0.3.0/24", "10.0.4.0/24"]
}
