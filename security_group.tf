resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow container port inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow http inbound traffic for alb"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb_sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow inbound traffic from ECS tasks to EFS mount targets"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
     security_groups = [aws_security_group.ecs_sg.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_security_group_rule" "rds_ingress" {
  security_group_id = aws_security_group.rds_sg.id
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
}
