variable "aws_region" {
  description = "AWS region for the ECR repository."
  type        = string
  default     = "ap-southeast-1"
}

variable "repository_name" {
  description = "Name of the ECR repository that stores the application image."
  type        = string
  default     = "goldenowl-devops-test"
}
