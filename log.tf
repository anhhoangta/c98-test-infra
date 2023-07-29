resource "aws_cloudwatch_log_group" "c98-app-log-group" {
  name = "c98-app-log-group"
  tags = {
    Environment = "development"
  }
}

resource "aws_cloudwatch_log_stream" "c98-app-log-client" {
  name = "c98-app-log-client"
  log_group_name = aws_cloudwatch_log_group.c98-app-log-group.name
}
