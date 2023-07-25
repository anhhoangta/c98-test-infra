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
