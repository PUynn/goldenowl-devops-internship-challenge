output "tf_state_bucket" {
  description = "S3 bucket used by the main Terraform backend."
  value       = aws_s3_bucket.state.bucket
}

output "tf_lock_table" {
  description = "DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.lock.name
}
