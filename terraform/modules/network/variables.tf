variable "certificate_arn" {
  description = "ARN of the SSL/TLS certificate"
  type        = string
  default     = null # Should be provided in tfvars
}

variable "alb_certificate_arn" {
  description = "ARN of the ALB certificate"
  type        = string
  default     = null # Should be provided in tfvars
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = null # Should be provided in tfvars
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = [] # Should be provided in tfvars
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
  default     = [] # Should be provided in tfvars
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
  default     = "quest-lambda-lb"
}

variable "is_internet_facing" {
  description = "Whether the load balancer is internet facing"
  type        = bool
  default     = true
}

variable "listener_port" {
  description = "Port number for the listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the listener"
  type        = string
  default     = "HTTP"
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "default_action_type" {
  description = "Type of the default action"
  type        = string
  default     = "fixed-response"
}

variable "response_content_type" {
  description = "Content type of the fixed response"
  type        = string
  default     = "text/plain"
}

variable "response_message" {
  description = "Message body of the fixed response"
  type        = string
  default     = "Load Balancer is configured"
}

variable "response_status_code" {
  description = "Status code of the fixed response"
  type        = string
  default     = "200"
}


