variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "lee-emp-bucket-unique"  # Ensure this name is globally unique
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "lee-process-and-store-lambda"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function deployment zip file"
  type        = string
  default     = "lambda/lambda_function_payload.zip"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "Lee-employee-1"  # Specify your DynamoDB table name here
}
