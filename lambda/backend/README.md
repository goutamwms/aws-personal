# Backend - Lambda S3 Upload

Node.js backend for a React application that uses AWS Lambda (with Lambda Function URL) to generate pre-signed S3 URLs for uploading and viewing files.

## Architecture

```
React App → Lambda Function URL → Lambda (Express) → S3 (pre-signed URLs)
```

The Lambda function runs an Express server (via `serverless-http`) and exposes three endpoints:

- **`POST /get-upload-url`** — Accepts `{ fileName, fileType }`, returns a pre-signed PUT URL (5 min expiry) for uploading to `uploads/<fileName>`.
- **`GET /view/:key`** — Returns a pre-signed GET URL (1 hour expiry) to view/download a file by its S3 key.
- **`GET /health`** — Returns `{ message: "Healthy" }`.

## Prerequisites

- Node.js 18+
- An S3 bucket
- AWS credentials configured (via environment variables, IAM role, or AWS CLI)

## Setup

```bash
npm install
```

## Configuration

Edit `index.js` and update the bucket name and region:

```js
const s3Client = new S3Client({ region: "us-east-1" });
const BUCKET_NAME = "your-s3-repo";
```

> **Note:** For production, move these to environment variables (`BUCKET_NAME`, `AWS_REGION`) and use `process.env`.

## Deployment

Deploy as a Lambda function with a **Lambda Function URL** enabled. The handler is:

```
index.handler
```

The `serverless-http` adapter converts Lambda Function URL events to Express requests. Make sure the function URL's **Auth type** is set to `NONE` if authentication is handled by the frontend, or `AWS_IAM` if using IAM-based auth.

## IAM Permissions

The Lambda execution role needs these S3 permissions:

```json
{
  "Effect": "Allow",
  "Action": ["s3:PutObject", "s3:GetObject"],
  "Resource": "arn:aws:s3:::your-s3-repo/uploads/*"
}
```

## Dependencies

- `express` — Web framework
- `serverless-http` — Lambda adapter for Express
- `@aws-sdk/client-s3` — S3 SDK v3
- `@aws-sdk/s3-request-presigner` — Pre-signed URL generation
- `cors` — CORS middleware
