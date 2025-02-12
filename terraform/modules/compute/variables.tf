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
