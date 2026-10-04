output "application_url" {
  description = "Public URL served by the application load balancer."
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}

output "load_balancer_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = aws_lb.main.dns_name
}

output "container_image_uri" {
  description = "ECR image URI deployed to ECS."
  value       = local.image_uri
}
