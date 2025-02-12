# modules/iam/outputs.tf
output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = var.lambda_role_name
}

output "policy_version" {
  description = "Version of the IAM policy"
  value       = var.policy_version
}

output "assume_role_action" {
  description = "Action for the assume role policy"
  value       = var.assume_role_action
}

output "assume_role_effect" {
  description = "Effect for the assume role policy"
  value       = var.assume_role_effect
}

output "lambda_service_principal" {
  description = "Service principal for Lambda"
  value       = var.lambda_service_principal
}

output "policy_attachment_name" {
  description = "Name of the policy attachment"
  value       = var.policy_attachment_name
}

output "lambda_policy_arn" {
  description = "ARN of the Lambda execution policy"
  value       = var.lambda_policy_arn
}
