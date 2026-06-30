locals {
  envs = ["dev", "staging", "prod"]

}

resource "aws_s3_bucket" "tfstate" {
  for_each = toset(local.envs)
  bucket   = "ec2-storage-tfstate-${each.key}-101"

#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  for_each = aws_s3_bucket.tfstate
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  for_each       = toset(local.envs)
  name           = "ec2-terraform-state-lock-${each.key}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = each.key
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  for_each = aws_s3_bucket.tfstate
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  for_each                = aws_s3_bucket.tfstate
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
