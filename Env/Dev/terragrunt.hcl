include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../modules/"
  # Path to the EC2 Terraform module
}

inputs = {
 
  s3_bucket_name       = "lee-emp-bucket-unique"
  dynamodb_table_name  = "Lee-employee-1"  # Ensure this matches the DynamoDB table name
  lambda_function_name = "lee-process-and-store-lambda"
  lambda_runtime       = "python3.9"
  lambda_zip_path      = "${get_repo_root()}/lambda/lambda_function_payload.zip"
}