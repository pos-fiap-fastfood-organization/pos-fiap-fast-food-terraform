# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Cluster EKS principal
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_capacity
      max_size       = 3
      min_size       = 1
      instance_types = [var.instance_type]
      disk_size      = 20
    }
  }

  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access_cidrs  = var.cluster_allowed_cidrs

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# IAM Role administrativa
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin_access" {
  name = "EKSAdminAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
  role       = aws_iam_role.eks_admin_access.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 👇 Submódulo para controle do aws-auth
module "aws_auth" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks//modules/aws-auth?ref=v20.8.5"

  manage_aws_auth_configmap = true

  depends_on = [module.eks]

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_admin_access.arn
      username = "eks-admin-access"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = var.kubernetes_user
      username = "fiap-pos-fast-food-github-terraform"
      groups   = ["system:masters"]
    }
  ]

  # conecta ao cluster criado
  eks_cluster_id = module.eks.cluster_name
}