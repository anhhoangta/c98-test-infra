variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "docker_image_tag" {
  description = "The tag of the Docker image to use"
  type        = string
  default     = "latest"
}
  
variable "docker_image_name" {
  description = "The name of the Docker image to use"
  type        = string
  default = "ghcr.io/anhhoangta/c98-test"
}

variable "container_port" {
  description = "The port to expose on the container"
  type        = number
  default     = 3000
}

variable "redis_cluster" {
  description = "Value of redis cluster"
  type        = map(any)
  default = {
    cluster_id           = "redis-cluster"
    engine               = "redis"
    node_type            = "cache.t3.small"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis3.2"
    engine_version       = "3.2.10"
    port                 = 6379
  }

}

variable "ecs_autoscale" {
  description = "Value of ecs autoscale"
  type        = map(any)
  default = {
    min_capacity = 1
    max_capacity = 10
    desired_capacity = 2
    cpu_threshold = 65.0
    memory_threshold = 65.0
    scale_in_cooldown = 30
    scale_out_cooldown = 30
  }
}

variable "ecs_task" {
  description = "Value of ecs task"
  type        = map(any)
  default = {
    cpu = "512"
    memory = "1024"
    family = "app-task"
    compute_platform = "FARGATE"
    volume_name = "app-storage"
  }
}
