# Frontend - S3 File Upload & Preview

A React single-page application that lets users select a file, upload it securely to an S3 bucket, and preview the uploaded file.

## How it works

1. The user picks a file via the file input.
2. On upload, the app requests a **presigned S3 PUT URL** from a backend Lambda function (invoked directly via its function URL).
3. The file is uploaded directly to S3 using that presigned URL.
4. The app then requests a **presigned S3 GET URL** from the Lambda to retrieve and display the file as an image preview.

The frontend never accesses AWS credentials or the S3 API directly — all S3 interactions go through presigned URLs generated server-side by the Lambda.
