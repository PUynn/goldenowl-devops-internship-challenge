variable "aws_region" {
  description = "AWS region for the Terraform state backend."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for backend resources."
  type        = string
  default     = "goldenowl-devops-test"
}
