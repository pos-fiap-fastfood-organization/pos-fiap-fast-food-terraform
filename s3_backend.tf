# Criação do bucket S3 para Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = "fiap-fastfood-terraform-state"  # escolha um nome único globalmente
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

# Configuração do backend S3
terraform {
  backend "s3" {
    bucket = aws_s3_bucket.tf_state.bucket
    key    = "eks/terraform.tfstate"
    region = var.aws_region
    encrypt = true
  }
}