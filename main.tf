terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# IAM (Lambda Execution Role)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "Quest_Lambda_Execution_Role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = "lambda_logging"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# COMPUTE (AWS Lambda Function)
data "archive_file" "quest_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/quest_lambda_src.zip"
}

resource "aws_lambda_function" "quest_lambda" {
  filename         = data.archive_file.quest_lambda.output_path
  function_name    = "Quest_Lambda"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.quest_lambda.output_base64sha256
  runtime          = "nodejs22.x"
  handler          = "lambda.handler" # Ensure 000.js has 'exports.handler'

  memory_size = 128
  timeout     = 15

  tracing_config {
    mode = "PassThrough"
  }

  ephemeral_storage {
    size = 512
  }
}
