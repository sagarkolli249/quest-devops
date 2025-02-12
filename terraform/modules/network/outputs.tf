# modules/network/outputs.tf
output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = var.load_balancer_name
}

output "is_internet_facing" {
  description = "Whether the load balancer is internet-facing"
  value       = var.is_internet_facing
}

output "security_groups" {
  description = "List of security group IDs"
  value       = var.security_groups
}

output "subnets" {
  description = "List of subnet IDs"
  value       = var.subnets
}

output "alb_certificate_arn" {
  description = "ARN of the ALB certificate"
  value       = var.alb_certificate_arn
}

output "load_balancer_type" {
  description = "Type of load balancer"
  value       = var.load_balancer_type
}

output "listener_port" {
  description = "Port for the listener"
  value       = var.listener_port
}

output "listener_protocol" {
  description = "Protocol for the listener"
  value       = var.listener_protocol
}

output "default_action_type" {
  description = "Type of the default action"
  value       = var.default_action_type
}

output "response_content_type" {
  description = "Content type of the fixed response"
  value       = var.response_content_type
}

output "response_message" {
  description = "Message body of the fixed response"
  value       = var.response_message
}

output "response_status_code" {
  description = "Status code of the fixed response"
  value       = var.response_status_code
}

# Additional outputs for load balancer ARN and DNS name
output "load_balancer_arn" {
  description = "ARN of the created load balancer"
  value       = aws_lb.load_balancer.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the created load balancer"
  value       = aws_lb.load_balancer.dns_name
}
