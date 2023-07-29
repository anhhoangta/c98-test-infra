data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "db-credentials"
}

data "aws_secretsmanager_secret_version" "aws_credentials" {
  secret_id = "aws-credentials"
}