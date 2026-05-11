terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

##########################################################
# DATE + TIMESTAMP
##########################################################

locals {

  # Bucket date format only
  current_date = formatdate("YYYYMMDD", timestamp())

  # Full timestamp for log file
  current_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())

  # Bucket name
  bucket_name = "my-free-demo-bucket-${local.current_date}"
}

##########################################################
# S3 BUCKET
##########################################################

resource "aws_s3_bucket" "myDemo" {

  bucket = local.bucket_name

  # Allows deletion even if bucket has files
  force_destroy = true

  tags = {
    Name = "BeginnerBucket"
  }
}

##########################################################
# STEP 1
# Upload hello.txt to bucket root
##########################################################

resource "aws_s3_object" "file_upload" {

  bucket = aws_s3_bucket.myDemo.id

  key = "hello.txt"

  source = "${path.module}/hello.txt"

  etag = filemd5("${path.module}/hello.txt")
}

##########################################################
# STEP 2
# Upload hello.txt inside current-user folder
##########################################################

resource "aws_s3_object" "file_upload_current_user" {

  bucket = aws_s3_bucket.myDemo.id

  key = "current-user/hello.txt"

  source = "${path.module}/hello.txt"

  etag = filemd5("${path.module}/hello.txt")
}

##########################################################
# STEP 3
# Create dynamic log file
##########################################################

resource "aws_s3_object" "log_file" {

  bucket = aws_s3_bucket.myDemo.id

  # Dynamic filename
  key = "current-user/log-${local.current_timestamp}.txt"

  # Dynamic file content
  content = "logged at ${local.current_timestamp}"
}

##########################################################
# OUTPUTS
##########################################################

output "bucket_name" {
  value = aws_s3_bucket.myDemo.bucket
}

output "file_url" {
  value = "https://${aws_s3_bucket.myDemo.bucket}.s3.amazonaws.com/hello.txt"
}

output "current_user_file_url" {
  value = "https://${aws_s3_bucket.myDemo.bucket}.s3.amazonaws.com/current-user/hello.txt"
}

output "log_file_url" {
  value = "https://${aws_s3_bucket.myDemo.bucket}.s3.amazonaws.com/current-user/log-${local.current_timestamp}.txt"
}