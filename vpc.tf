locals {
  all_subnets = concat(aws_subnet.app_public_subnets.*.id, aws_subnet.app_private_subnets.*.id)
}

resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "app_public_subnets" {
  count             = length(var.azs)
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = var.azs[count.index]
}

resource "aws_subnet" "app_private_subnets" {
  count             = length(var.azs)
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + length(var.azs))
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = var.azs[count.index]
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.app_public_subnets[0].id
}

resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  count = length(aws_subnet.app_public_subnets)

  subnet_id      = aws_subnet.app_public_subnets[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.app_public_subnets.*.id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_route_table_association" "app_private_route_table_association" {
  count = length(aws_subnet.app_private_subnets)

  subnet_id      = aws_subnet.app_private_subnets[count.index].id
  route_table_id = aws_route_table.my_private_route_table.id
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
  target_type = "ip"

  health_check {
    path = "/health"
    port = 3000
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200-499"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
