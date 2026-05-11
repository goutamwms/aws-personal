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
# LOCALS
##########################################################

locals {

  current_date = formatdate("YYYY-MM-DD", timestamp())

  start_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())

  bucket_name = "experiment-${local.current_date}"
}

##########################################################
# S3 BUCKET
##########################################################

resource "aws_s3_bucket" "experiment_bucket" {

  bucket = local.bucket_name

  force_destroy = true

  tags = {
    Name = "TerraformExperiment"
  }
}

##########################################################
# CREATE DYNAMIC FILES
##########################################################

resource "aws_s3_object" "dynamic_files" {

  count = var.file_count

  bucket = aws_s3_bucket.experiment_bucket.id

  key = "dynamic/${count.index + 1}.txt"

  content = tostring(count.index + 1)
}

##########################################################
# COMPLETE FILE
##########################################################

resource "aws_s3_object" "complete_file" {

  depends_on = [aws_s3_object.dynamic_files]

  bucket = aws_s3_bucket.experiment_bucket.id

  key = "complete.txt"

  content = <<EOT
started at: ${local.start_timestamp}
completed at: ${formatdate("YYYYMMDDhhmmss", timestamp())}
EOT
}

##########################################################
# OUTPUTS
##########################################################

output "bucket_name" {
  value = aws_s3_bucket.experiment_bucket.bucket
}

output "dynamic_folder" {
  value = "dynamic/"
}