output "state_bucket_name" {
  description = "Name of the S3 bucket that holds Terraform state. Use it in the backend block of other configurations."
  value       = aws_s3_bucket.state.id
}

output "region" {
  description = "Region the state bucket lives in."
  value       = var.region
}
