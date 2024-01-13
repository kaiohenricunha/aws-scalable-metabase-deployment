module "lab_vpc" {
  source  = "../../infra/vpc"

  name    = "lab-vpc"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "lab"
    GithubRepo = "aws-scalable-metabase-deployment"
    GithubOrg  = "kaiohenricunha"
  }
}
