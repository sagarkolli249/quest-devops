# modules/compute/main.tf
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
