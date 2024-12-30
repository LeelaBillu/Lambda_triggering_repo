remote_state {
  backend = "s3"
  config = {
    bucket         = "lee-bucket-1"  # S3 bucket for storing the state files
    key            = "terragrunt/state/${path_relative_to_include()}/terraform.tfstate"  # Dynamic state file path
    region         = "us-east-1"      # AWS region for the S3 bucket
    encrypt        = true             # Enable encryption for state files
    dynamodb_table = "my-lock-table" # DynamoDB table for state locking
  }
}


generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}
