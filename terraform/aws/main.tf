provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "meu_bucket" {
  bucket = var.bucket_name
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.meu_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
