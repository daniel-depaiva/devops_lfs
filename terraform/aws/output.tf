output "bucket_name" {
  value = aws_s3_bucket.meu_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.meu_bucket.arn
}