terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "fiap-fastfood-terraform-state"  # nome do bucket S3
    key            = "eks/terraform.tfstate"          # caminho dentro do bucket
    region         = "us-east-2"                      # região do bucket
    encrypt        = true                             # criptografia do state
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}
