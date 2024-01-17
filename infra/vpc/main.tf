module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = ["10.0.64.0/19", "10.0.96.0/19", "10.0.128.0/19"]
  public_subnets  = ["10.0.160.0/19", "10.0.192.0/19", "10.0.224.0/19"]
  intra_subnets   = ["10.0.0.0/19", "10.0.32.0/19"]

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "metabaselab"
  }

  tags = var.tags
}
