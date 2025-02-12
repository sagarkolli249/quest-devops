module "compute" {
  source                 = "./modules/compute"
  lambda_image_uri       = module.compute.lambda_image_uri
  lambda_role_arn        = module.compute.lambda_role_arn
  function_name          = module.compute.function_name
  package_type           = module.compute.package_type
  architectures          = module.compute.architectures
  runtime                = module.compute.runtime
  memory_size            = module.comput.memory_size
  timeout                = module.compute.timeout
  secret_word            = module.compute.secret_word
  tracing_mode           = module.compute.tracing_mode
  ephemeral_storage_size = module.compute.ephemeral_storage_size
}

module "network" {
  source                = "./modules/network"
  listener_port         = module.netowork.listener_port
  subnets               = module.netowork.subnets
  security_groups       = module.netowork.security_groups
  load_balancer_name    = module.netowork.load_balancer_name
  is_internet_facing    = module.netowork.is_internet_facing
  listener_protocol     = module.netowork.listener_protocol
  certificate_arn       = module.netowork.certificate_arn
  alb_certificate_arn   = module.netowork.alb_certificate_arn
  vpc_id                = module.netowork.vpc_id
  load_balancer_type    = module.network.load_balancer_type
  default_action_type   = module.network.default_action_type
  response_content_type = module.network.response_content_type
  response_message      = module.network.response_message
  response_status_code  = module.network.response_status_code
}

module "iam" {
  source                   = "./modules/iam"
  lambda_role_name         = module.iam.lambda_role_name
  policy_version           = module.iam.policy_version
  assume_role_action       = module.iam.assume_role_action
  assume_role_effect       = module.iam.assume_role_effect
  lambda_service_principal = module.iam.lambda_service_principal
  policy_attachment_name   = module.iam.policy_attachment_name
  lambda_policy_arn        = module.iam.lambda_policy_arn
}

module "storage" {
  source              = "./modules/storage"
  s3_bucket_name      = module.storage.s3_bucket_name
  dynamodb_table_name = module.storage.dynamodb_table_name
  aws_region          = module.storage.aws_region
  versioning_status   = module.storage.versioning_status
  sse_algorithm       = module.storage.sse_algorithm
  billing_mode        = module.storage.billing_mode
  hash_key            = module.storage.hash_key
  hash_key_type       = module.storage.hash_key_type
}
