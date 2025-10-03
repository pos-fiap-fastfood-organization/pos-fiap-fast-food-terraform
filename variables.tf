variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "fiap-fastfood-eks"
}

variable "desired_capacity" {
  description = "Quantidade de nós no Node Group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Tipo de instância EC2 para os nodes"
  type        = string
  default     = "t3.micro"
}