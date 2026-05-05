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

# Generate a unique name using timestamp
locals {
  bucket_name = "my-free-demo-bucket-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

resource "aws_s3_bucket" "myDemo" {
  bucket = local.bucket_name

  tags = {
    Name = "BeginnerBucket"
  }
}

/*
output "bucket_name" {
  value = aws_s3_bucket.myDemo.bucket
}
*/

# Upload file to S3
resource "aws_s3_object" "file_upload" {
  bucket = aws_s3_bucket.myDemo.id
  key    = "hello.txt"         # file name in S3
  source = "hello.txt"         # local file path

  etag = filemd5("hello.txt") # ensures updates if file changes
}

# Output
output "bucket_name" {
  value = aws_s3_bucket.myDemo.bucket
}

output "file_url" {
  value = "https://${aws_s3_bucket.myDemo.bucket}.s3.amazonaws.com/hello.txt"
}