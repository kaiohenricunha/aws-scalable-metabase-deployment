terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
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

provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr_block             = "10.0.0.0/16"
  vpc_name                   = "lab-vpc"
  availability_zones         = ["us-west-2a", "us-west-2b"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidr_blocks  = ["10.0.3.0/24", "10.0.4.0/24"]
}
