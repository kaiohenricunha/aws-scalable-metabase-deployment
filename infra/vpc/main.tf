module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "profile"                = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "metabaselab"
    "profile"                = "private"
  }

  tags = var.tags
}
