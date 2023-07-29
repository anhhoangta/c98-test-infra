locals {
  aws-credentials = jsondecode(data.aws_secretsmanager_secret_version.aws_credentials.secret_string)
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family = "app-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  volume {
    name = "app-storage"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.app_storage.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id       = aws_efs_access_point.efs_access_point.id
        iam                   = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([{
    name = "app-container"
    image = "${var.docker_image_name}:${var.docker_image_tag}"

    environment = [
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = local.aws-credentials.AWS_ACCESS_KEY_ID
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = local.aws-credentials.AWS_SECRET_ACCESS_KEY
        }
      ]
    
    portMappings = [{
      containerPort = var.container_port
      hostPort = var.container_port
      protocol = "tcp"
    }]
    mountPoints  = [{
      sourceVolume   = "app-storage"
      containerPath  = "/app/data/uploads"
      readOnly       = false
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = "c98-app-log-group"
        awslogs-region = "us-east-1"
        awslogs-stream-prefix = "c98-app-log-client"
      }
    }
  }])
}

resource "aws_ecs_service" "app_service" {
  name = "app-service"
  cluster = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = aws_subnet.app_private_subnets.*.id
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "app-container"
    container_port   = var.container_port
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role"
  
   assume_role_policy = jsonencode({
     Version= "2012-10-17",
     Statement= [
       {
         Action= "sts:AssumeRole",
         Effect= "Allow",
         Principal= {
           Service= [
             "ecs-tasks.amazonaws.com",
           ]
         }
       }
     ]
   })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.efs_policy.arn
}