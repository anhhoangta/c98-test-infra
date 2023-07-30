resource "aws_elasticache_subnet_group" "redis-subnets" {
  name       = "redis-subnets"
  subnet_ids = aws_subnet.app_private_subnets.*.id
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.redis_cluster.cluster_id
  engine               = var.redis_cluster.engine
  node_type            = var.redis_cluster.node_type
  num_cache_nodes      = var.redis_cluster.num_cache_nodes
  parameter_group_name = var.redis_cluster.parameter_group_name
  engine_version       = var.redis_cluster.engine_version
  port                 = var.redis_cluster.port
  subnet_group_name = aws_elasticache_subnet_group.redis-subnets.name
  security_group_ids = [aws_security_group.redis-sg.id]
}