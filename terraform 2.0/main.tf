terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}

provider "aws" {
  # Configuration options
}

# Storage
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

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }
}

# Netowrk
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

resource "aws_lb" "load_balancer" {
  name               = var.load_balancer_name
  internal           = !var.is_internet_facing
  security_groups    = var.security_groups
  subnets            = var.subnets
  arn                = var.alb_certificate_arn
  load_balancer_type = var.load_balancer_type
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = var.default_action_type
    fixed_response {
      content_type = var.response_content_type
      message_body = var.response_message
      status_code  = var.response_status_code
    }
  }
}

# IAM
variable "lambda_role_name" {
  type = string
}

variable "policy_version" {
  type = string
}

variable "assume_role_action" {
  type = string
}

variable "assume_role_effect" {
  type = string
}

variable "lambda_service_principal" {
  type = string
}

variable "policy_attachment_name" {
  type = string
}

variable "lambda_policy_arn" {
  type = string
}

resource "aws_iam_role" "lambda_exec" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = var.policy_version
    Statement = [
      {
        Action    = var.assume_role_action
        Effect    = var.assume_role_effect
        Principal = { Service = var.lambda_service_principal }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = var.policy_attachment_name
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = var.lambda_policy_arn
}

# Compute
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "Quest_Lambda"
}

variable "package_type" {
  description = "Lambda deployment package type"
  type        = string
  default     = "Image"
}

variable "lambda_image_uri" {
  description = "URI of the container image"
  type        = string
}

variable "architectures" {
  description = "Instruction set architecture for Lambda function"
  type        = list(string)
  default     = ["x86_64"]
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 15
}

variable "secret_word" {
  description = "Secret word to be passed as environment variable"
  type        = string
}

variable "tracing_mode" {
  description = "X-Ray tracing mode"
  type        = string
  default     = "PassThrough"
}

variable "ephemeral_storage_size" {
  description = "Size of ephemeral storage in MB"
  type        = number
  default     = 512
}

resource "aws_lambda_function" "quest_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  package_type  = var.package_type
  image_uri     = var.lambda_image_uri
  architectures = var.architectures
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = {
      SECRET_WORD = var.secret_word
    }
  }

  tracing_config {
    mode = var.tracing_mode
  }

  ephemeral_storage {
    size = var.ephemeral_storage_size
  }
}
