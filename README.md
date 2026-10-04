# Golden Owl DevOps Internship Challenge

This repository contains a containerized Node.js application and a complete DevOps delivery setup for the Golden Owl DevOps Internship technical challenge. The solution uses Docker, GitHub Actions, AWS ECR, AWS ECS Fargate, an Application Load Balancer, ECS auto scaling, and Terraform-managed infrastructure.

## Submission Information

| Requirement | Value |
| --- | --- |
| Public GitHub repository | https://github.com/PUynn/goldenowl-devops-internship-challenge |
| Deployment link | ......... |
| Visual flow diagram | .......... |
| Final Docker image size | maybe ..... |


## Project Overview

The application is a small Express.js service that returns a JSON response from the root route:

```json
{
  "message": "Welcome warriors to Golden Owl!"
}
```

The repository is structured so that the application, Docker image, CI/CD workflows, and cloud infrastructure can be reviewed independently.

```text
.
|-- .github/workflows/      # GitHub Actions CI and CD workflows
|-- docs/                   # Visual diagram checklist and exported diagram
|-- src/                    # Node.js application source code and tests
|-- terraform/              # AWS application infrastructure
|   |-- bootstrap/          # Remote Terraform state resources
|   `-- ecr/                # ECR repository infrastructure
|-- Dockerfile              # Optimized production Docker image
`-- README.md
```

## Technology Stack

- Runtime: Node.js 20 and Express.js
- Testing: Jest and Supertest
- Code quality: ESLint and Prettier
- Containerization: Docker with a multi-stage production build
- CI/CD: GitHub Actions
- Container registry: Amazon Elastic Container Registry
- Cloud platform: AWS
- Compute: AWS ECS Fargate
- Traffic management: AWS Application Load Balancer
- Auto scaling: ECS target tracking policies for CPU and memory
- Infrastructure as Code: Terraform
- Security scanning: Trivy

## Local Development

Install dependencies and start the application:

```bash
cd src
npm ci
npm start
```

The application listens on port `3000` by default.

```bash
curl http://localhost:3000
```

Run quality checks locally:

```bash
cd src
npm run format:check
npm run lint:check
npm test
```

## Docker

Build the production image from the repository root:

```bash
docker build -t goldenowl-devops-test:local .
```

Inspect the image size:

```bash
docker image inspect goldenowl-devops-test:local --format='{{.Size}}'
```

The Dockerfile is optimized by:

- Using `node:20-alpine` as a lightweight base image
- Installing only production dependencies with `npm ci --omit=dev`
- Separating dependency installation from the runtime image
- Running the application as a non-root user
- Excluding development-only files through `.dockerignore`

## CI Pipeline

Workflow: `.github/workflows/ci.yml`

The CI pipeline runs on:

- Pushes to `main`
- Pushes to `feature/**`
- Pushes to `feat/**`
- Pull requests

CI jobs include:

- Installing Node.js dependencies with `npm ci`
- Checking formatting with Prettier
- Running ESLint
- Running Jest tests
- Building the Docker image
- Printing the Docker image size
- Scanning the Docker image with Trivy for HIGH and CRITICAL vulnerabilities

## CD Pipeline

Workflow: `.github/workflows/deploy.yml`

The CD pipeline runs on:

- Pushes to `main`
- Manual `workflow_dispatch`

Deployment steps include:

- Installing dependencies
- Running tests
- Configuring AWS credentials
- Running Terraform format checks
- Creating or updating the ECR repository with Terraform
- Building and pushing the Docker image to ECR
- Scanning the pushed image with Trivy
- Creating or updating the AWS application infrastructure with Terraform
- Printing the Application Load Balancer URL

## Required GitHub Secrets

Configure these secrets in `Settings -> Secrets and variables -> Actions` before running the deployment workflow:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
TF_STATE_BUCKET
TF_LOCK_TABLE
```

## Infrastructure

### Remote State

The bootstrap stack creates:

- An S3 bucket for Terraform remote state
- A DynamoDB table for Terraform state locking
- Server-side encryption and public access blocking for the state bucket

Bootstrap once:

```bash
terraform -chdir=terraform/bootstrap init
terraform -chdir=terraform/bootstrap apply
```

### ECR Stack

The `terraform/ecr` stack creates:

- An ECR repository
- Image scan-on-push
- AES-256 repository encryption
- Lifecycle policy that keeps the latest 10 images

### Application Stack

The main `terraform` stack creates:

- VPC with DNS support
- Two public subnets across separate availability zones
- Internet gateway and public route table
- Application Load Balancer
- ALB target group and HTTP listener
- ECS cluster with container insights enabled
- ECS Fargate task definition and service
- ECS task execution IAM role
- CloudWatch log group
- ECS deployment circuit breaker with automatic rollback
- ECS service auto scaling target
- CPU target tracking policy at 60 percent
- Memory target tracking policy at 70 percent

Default ECS capacity:

| Setting | Value |
| --- | --- |
| Desired tasks | `2` |
| Minimum tasks | `2` |
| Maximum tasks | `4` |
| Task CPU | `256` |
| Task memory | `512 MiB` |
| Container port | `3000` |

## Manual Deployment Commands

GitHub Actions handles deployment automatically, but the infrastructure can also be applied locally.

Initialize and apply the ECR stack:

```bash
terraform -chdir=terraform/ecr init \
  -backend-config="bucket=<TF_STATE_BUCKET>" \
  -backend-config="key=goldenowl-devops-test/ecr.tfstate" \
  -backend-config="region=<AWS_REGION>" \
  -backend-config="dynamodb_table=<TF_LOCK_TABLE>" \
  -backend-config="encrypt=true"

terraform -chdir=terraform/ecr apply \
  -var="aws_region=<AWS_REGION>"
```

Build and push the image manually:

```bash
ECR_REPOSITORY_URL=$(terraform -chdir=terraform/ecr output -raw ecr_repository_url)
ECR_REGISTRY="${ECR_REPOSITORY_URL%/*}"

aws ecr get-login-password --region <AWS_REGION> \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker build -t "$ECR_REPOSITORY_URL:latest" .
docker push "$ECR_REPOSITORY_URL:latest"
```

Initialize and apply the application stack:

```bash
terraform -chdir=terraform init \
  -backend-config="bucket=<TF_STATE_BUCKET>" \
  -backend-config="key=goldenowl-devops-test/terraform.tfstate" \
  -backend-config="region=<AWS_REGION>" \
  -backend-config="dynamodb_table=<TF_LOCK_TABLE>" \
  -backend-config="encrypt=true"

terraform -chdir=terraform apply \
  -var="aws_region=<AWS_REGION>" \
  -var="image_tag=latest"
```

Get the deployment URL:

```bash
terraform -chdir=terraform output application_url
```

