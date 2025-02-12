variable "target_group_defined" {
  type        = bool
  description = "Indicates whether a target group is defined for the load balancer"
  default = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
  default = "your-bucket-name"
}

variable "versioning_status" {
  description = "Versioning state of the bucket (Enabled/Disabled)"
  type        = string
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use (AES256 or aws:kms)"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
}

variable "hash_key" {
  description = "Hash key for DynamoDB table"
  type        = string
}

variable "hash_key_type" {
  description = "Type of the hash key (S for string, N for number, B for binary)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}