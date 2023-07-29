locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.app_private_subnets[0].id, aws_subnet.app_private_subnets[1].id]
}

resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.8"
  instance_class       = "db.t3.small"
  db_name              = local.db_credentials.db_name
  username             = local.db_credentials.db_username
  password             = local.db_credentials.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}
