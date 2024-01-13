module "backend" {
  source              = "../../../infra/backend"
  region              = "us-east-1"
  bucket_name         = "tfstate-kaio-lab"
  dynamodb_table_name = "tfstate-kaio-lab-lock"
}
