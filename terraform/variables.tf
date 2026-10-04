variable "aws_region" {
  description = "AWS region for the application infrastructure."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for AWS resources."
  type        = string
  default     = "goldenowl-devops-test"
}

variable "ecr_repository_name" {
  description = "ECR repository name that stores the application image."
  type        = string
  default     = "goldenowl-devops-test"
}

variable "image_tag" {
  description = "Container image tag deployed to ECS."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the Node.js container."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Initial number of ECS tasks."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks."
  type        = number
  default     = 4
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/"
}
