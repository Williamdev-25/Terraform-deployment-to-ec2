terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket       = "ec2-storage-tfstate-prod-101"
    key          = "prod/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}