terraform {
  backend "s3" {
    bucket  = "tfstate-kaio-lab"
    key     = "tfstate-kaio-lab-lock"
    region  = "us-east-1"
    encrypt = true
  }
}
