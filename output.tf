output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}