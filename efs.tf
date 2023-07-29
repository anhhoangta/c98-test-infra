resource "aws_efs_file_system" "app_storage" {
  creation_token = "my-product"
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.app_storage.id
}

resource "aws_efs_mount_target" "efs_mount_target" {    
  count = length(aws_subnet.app_private_subnets)
  file_system_id  = aws_efs_file_system.app_storage.id
  subnet_id = aws_subnet.app_private_subnets[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_iam_policy" "efs_policy" {
  name        = "efs-policy"
  description = "EFS access policy for ECS task role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = "arn:aws:elasticfilesystem:us-east-1:964779800191:file-system/${aws_efs_file_system.app_storage.id}"
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = "arn:aws:elasticfilesystem:us-east-1:964779800191:access-point/${aws_efs_access_point.efs_access_point.id}"
          }
        }
      }
    ]
  })
}

