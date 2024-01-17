module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.db_name}-default"

  create_db_option_group    = false
  create_db_parameter_group = false

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  apply_immediately = true

  tags = var.tags
}
