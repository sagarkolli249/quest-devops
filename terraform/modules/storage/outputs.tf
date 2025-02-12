# modules/storage/outputs.tf
output "target_group_defined" {
  description = "Indicates whether a target group is defined for the load balancer"
  value       = var.target_group_defined
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  value       = var.s3_bucket_name
}

output "versioning_status" {
  description = "Versioning state of the bucket"
  value       = var.versioning_status
}

output "sse_algorithm" {
  description = "Server-side encryption algorithm used"
  value       = var.sse_algorithm
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = var.dynamodb_table_name
}

output "billing_mode" {
  description = "DynamoDB billing mode"
  value       = var.billing_mode
}

output "hash_key" {
  description = "Hash key for DynamoDB table"
  value       = var.hash_key
}

output "hash_key_type" {
  description = "Type of the hash key"
  value       = var.hash_key_type
}

output "aws_region" {
  description = "The AWS region where resources are deployed"
  value       = var.aws_region
}

# Additional useful outputs
output "s3_bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_arn" {
  description = "ARN of the created DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}
