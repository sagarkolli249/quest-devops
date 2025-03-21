provider "aws" {
  region = "us-east-1"
}

# VPC with minimal setup for Free Tier
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Updated to latest version

  name = "sec-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"] # Added a second AZ
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # Added second private subnet
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # Added second public subnet

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_ecr_repository" "sec_repo" {
  name                 = "sec-app-repo"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_iam_policy" "ecr_access" {
  name        = "ECRAccessPolicy"
  description = "Allows EKS to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability"],
        Resource = aws_ecr_repository.sec_repo.arn
      },
      {
        Effect   = "Allow",
        Action   = "ecr:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0" # Updated to latest version

  cluster_name    = "sec-eks"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # Using private subnets in two AZs
  enable_irsa = true

  eks_managed_node_groups = {
    free_nodes = {
      desired_size = 1
      max_size     = 1
      min_size     = 1
      instance_types = ["t3.micro"]
    }
  }
}

resource "null_resource" "install_ingress_nginx" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region us-east-1 update-kubeconfig --name secure-eks
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
    EOT
  }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.sec_repo.repository_url
}