resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family = "my-task"
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
    name = "my-container"
    image = "${var.docker_image_name}:${var.docker_image_tag}"
    portMappings = [{
      containerPort = var.container_port
      hostPort = var.container_port
      protocol = "tcp"
    }]
    mountPoints  = [{
      sourceVolume   = "app-storage"
      containerPath  = "/data"
      readOnly       = false
    }]
  }])
}

resource "aws_ecs_service" "my_service" {
  name = "my-service"
  cluster = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = aws_subnet.my_subnets.*.id
    security_groups = [aws_security_group.my_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "my-container"
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
