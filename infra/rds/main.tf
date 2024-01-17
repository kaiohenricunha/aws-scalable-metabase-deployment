module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "labrds"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  manage_master_user_password         = true
  iam_database_authentication_enabled = true

  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_ids             = var.subnet_ids

  multi_az          = true
  db_subnet_group_name = module.vpc.database_subnet_group

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "lab"
  }

  family               = "mysql5.7"
  major_engine_version = "5.7"
  deletion_protection  = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
