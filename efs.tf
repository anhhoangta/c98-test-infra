resource "aws_efs_file_system" "app_storage" {
  creation_token = "my-product"
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.app_storage.id
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.azs)
  file_system_id  = aws_efs_file_system.app_storage.id
  subnet_id = aws_subnet.my_subnets[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}