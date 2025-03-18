provider "aws" {
  region = "us-east-1"
}

# VPC with minimal setup for Free Tier
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Updated to latest version

  name = "secure-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_ecr_repository" "secure_repo" {
  name                 = "secure-app-repo"
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
        Resource = aws_ecr_repository.secure_repo.arn
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

  cluster_name    = "secure-eks"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
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

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.secure_repo.repository_url
}