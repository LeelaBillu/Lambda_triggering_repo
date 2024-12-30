import json
import boto3
import csv
from io import StringIO

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Lee-employee-1')  # DynamoDB table name

def lambda_handler(event, context):
    # Get the S3 bucket and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    s3 = boto3.client('s3')
    
    # Retrieve the file from S3
    response = s3.get_object(Bucket=bucket_name, Key=key)
    file_content = response['Body'].read().decode('utf-8')
    
    # Assuming the file is CSV format
    csv_reader = csv.DictReader(StringIO(file_content))
    
    # Process each row in the CSV file
    for row in csv_reader:
        username = row['username']
        empid = row['empid']
        email = row['email']
        
        # Insert data into DynamoDB
        table.put_item(
            Item={
                'empid': empid,
                'username': username,
                'email': email
            }
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed the file and updated DynamoDB')
    }
