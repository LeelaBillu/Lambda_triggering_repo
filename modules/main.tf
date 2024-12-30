
terraform {
    backend "s3" {}
}
# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy Attachments for Lambda Role (S3, DynamoDB, and CloudWatch Permissions)
resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# S3 Bucket (lee-emp-bucket-unique)
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = var.s3_bucket_name
  }
}

# DynamoDB Table (leela-employee)
resource "aws_dynamodb_table" "files_table" {
  name         = var.dynamodb_table_name
  hash_key     = "empid"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "empid"
    type = "S"
  }

  tags = {
    Name = "leela-employee"
  }
}

# Lambda Function (lee-process-and-store-lambda) - Handle Upload and Store in DynamoDB
resource "aws_lambda_function" "process_and_store_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = var.lambda_zip_path  # Path to the zip file
  source_code_hash = filebase64sha256(var.lambda_zip_path)
}

# S3 Event Notification to Trigger Lambda Function
resource "aws_s3_bucket_notification" "s3_event" {
  bucket = aws_s3_bucket.bucket.bucket

  lambda_function {
    events             = ["s3:ObjectCreated:*"]
    filter_suffix      = ".csv"  # Optional: Only trigger for .csv files
    lambda_function_arn = aws_lambda_function.process_and_store_lambda.arn
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# Lambda Permission to Allow S3 to Trigger Lambda Function
resource "aws_lambda_permission" "allow_s3_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_and_store_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
