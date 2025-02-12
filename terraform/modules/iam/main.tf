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
