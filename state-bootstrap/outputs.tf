output "tfstate_buckets" {
  value = { for env, bucket in aws_s3_bucket.tfstate : env => bucket.id }
}