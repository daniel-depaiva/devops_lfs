variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
  default     = "meu-bucket-devsecops-essex"
}

variable "environment" {
  description = "Ambiente para tag do bucket"
  type        = string
  default     = "dev"
}
