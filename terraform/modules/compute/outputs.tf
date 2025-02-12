# modules/compute/outputs.tf
output "function_name" {
  description = "Name of the Lambda function"
  value       = var.function_name
}

output "package_type" {
  description = "Lambda deployment package type"
  value       = var.package_type
}

output "lambda_image_uri" {
  description = "URI of the container image"
  value       = var.lambda_image_uri
}

output "architectures" {
  description = "Instruction set architecture for Lambda function"
  value       = var.architectures
}

output "runtime" {
  description = "Runtime environment for the Lambda function"
  value       = var.runtime
}

output "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  value       = var.memory_size
}

output "timeout" {
  description = "Timeout for the Lambda function in seconds"
  value       = var.timeout
}

output "secret_word" {
  description = "Secret word passed as environment variable"
  value       = var.secret_word
  sensitive   = true  # Since this is a secret value
}

output "tracing_mode" {
  description = "X-Ray tracing mode"
  value       = var.tracing_mode
}

output "ephemeral_storage_size" {
  description = "Size of ephemeral storage in MB"
  value       = var.ephemeral_storage_size
}
