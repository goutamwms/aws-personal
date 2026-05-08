# AWS S3 Deployment Experiments — Student Learning Project

This repo demonstrates four different approaches to working with **AWS S3** through hands-on experiments. Each approach is isolated in its own directory, designed for students to understand real-world cloud workflows.

---

## Table of Contents

1. [GitHub Actions → S3 Sync](#1-github-actions--s3-sync)
2. [Terraform — Dynamic S3 Bucket](#2-terraform--dynamic-s3-bucket)
3. [React + Lambda Backend — Presigned URL Upload & View](#3-react--lambda-backend--presigned-url-upload--view)
4. [Built SPA (Sample Blog)](#4-built-spa-sample-blog)

---

## 1. GitHub Actions → S3 Sync

**Location:** `.github/workflows/sync_to_s3.yml`

A CI/CD pipeline that **automatically syncs static files** to an S3 bucket whenever code is pushed to `main`.

**What it teaches:**
- Setting up OIDC / IAM credentials via GitHub Secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Using `aws-actions/configure-aws-credentials` to authenticate from CI
- Selective file sync with `aws s3 sync` using `--include` / `--exclude` patterns
- Deploying a static site to S3 with zero manual steps

**Key snippet:**
```yaml
- name: Sync selected files to S3
  run: |
    aws s3 sync . s3://owsome-s3 \
      --exclude "*" \
      --include "*.html" --include "*.css" --include "*.js" \
      --include "*.png" --include "*.jpg" --include "*.svg" --delete
```

---

## 2. Terraform — Dynamic S3 Bucket

**Location:** `terraform/`

Infrastructure-as-Code using **HashiCorp Terraform** to provision an S3 bucket and upload a sample file — all programmatically.

**What it teaches:**
- Declarative resource definition (`.tf` files)
- Using `timestamp()` for unique dynamic bucket names
- Uploading a local file as an S3 object with `aws_s3_object`
- Outputting resources (bucket name, public URL) for reuse

**Quick start:**
```bash
cd terraform
terraform init
terraform apply
```

---

## 3. React + Lambda Backend — Presigned URL Upload & View

**Location:**
- Backend: `lambda/backend/` (Express.js + serverless-http)
- Frontend: `lambda/frontend/` (React 19 + Vite 8 + TypeScript 6)

A full-stack serverless app that uploads files to S3 and previews them using **presigned URLs** — without any API Gateway or public bucket policy.

### Architecture
```
React App  ──POST /get-upload-url──→  Lambda (Express)
     │                                       │
     │  presigned PUT URL                    │  generates S3 presigned URL
     │                                       │
     ▼                                       ▼
   S3 Bucket  ◄──────────────────  AWS SDK (S3 Client)
     │
     │  presigned GET URL
     ▼
  Preview <img>
```

### What it teaches:
- **Presigned URLs** — secure, time-limited access to S3 without making buckets public
- **Lambda Function URL** — expose Express apps via serverless-http without API Gateway
- **Separation of concerns** — frontend never sees AWS credentials
- **React + Vite** — modern toolchain with TypeScript, ESLint, LightningCSS

### Endpoints (Backend)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/get-upload-url` | Get a presigned PUT URL (body: `{ fileName, fileType }`) |
| `GET`  | `/view/:key` | Get a presigned GET URL for viewing |
| `GET`  | `/health` | Health check |

### Running the Frontend
```bash
cd lambda/frontend
npm install
npm run dev
```

Update `API_BASE` in `src/App.tsx` with your Lambda Function URL before running.

---

## 4. Built SPA (Sample Blog)

**Location:** root (`index.html`, `assets/`, `favicon.svg`)

The production build output of a blog SPA ("Sample Blog") deployed to S3 via the GitHub Actions workflow.

**Tech stack:** React 19 + React Router + Framer Motion + Tailwind CSS v4

---

## Prerequisites

- Node.js 18+
- AWS account with programmatic access
- Terraform (for the IaC experiment)
- Git + GitHub (for CI/CD)

## Learning Path (Suggested Order)

1. Start with **Terraform** — understand S3 resources
2. Move to **GitHub Actions** — see how CI/CD automates deployment
3. Build the **Lambda backend** — understand presigned URLs
4. Connect the **React frontend** — see the full stack in action

---

## License

ISC — free for learning and experimentation.
