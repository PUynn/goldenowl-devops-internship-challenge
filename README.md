# Golden Owl DevOps Internship Challenge

This repository contains a containerized Node.js application and a complete DevOps delivery setup for the Golden Owl DevOps Internship technical challenge. The solution uses Docker, GitHub Actions, AWS ECR, AWS ECS Fargate, an Application Load Balancer, ECS auto scaling, and Terraform-managed infrastructure.

## Submission Guidelines 📬

Your solution should be showcased in a public GitHub repository. We encourage you to commit early and often. We prefer to see a history of iterative progress rather than a single massive push.

Your submission must include:

- The URL of your public GitHub repository
- The deployment link of your running application
- The visual flow diagram, manually created and not AI-generated
- The final Docker image size

### Submission Information

| Requirement | Value |
| --- | --- |
| Public GitHub repository | https://github.com/PUynn/goldenowl-devops-internship-challenge |
| Deployment link | To be updated with the Application Load Balancer URL after deployment. Run `terraform -chdir=terraform output application_url` or check the `Show deployment URL` step in GitHub Actions. |
| Visual flow diagram | To be exported manually into `docs/` using draw.io, Excalidraw, or Eraser. See `docs/visual-diagram-checklist.md`. |
| Final Docker image size | `49,156,534 bytes` / `46.88 MiB` measured from `docker image inspect goldenowl-devops-test:readme --format='{{.Size}}'`. |

## Your Mission 🌟

The mission is to build a CI/CD pipeline and deploy the application by:

1. Forking the repository to a personal GitHub account.
2. Dockerizing a Node.js application and keeping the image as lightweight as possible.
3. Establishing an automated CI/CD build process using GitHub Actions and a container registry service.
4. Initiating CI tests automatically when changes are pushed to a feature branch on GitHub.
5. Using GitHub Actions for Continuous Deployment to deploy the application to AWS.
6. Deploying the application behind a load balancer with auto scaling enabled.
7. Provisioning all cloud infrastructure using Infrastructure as Code.
8. Providing a visual flow diagram of the workflow and architecture, created manually without AI.

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

For a production-grade setup, GitHub OIDC with least-privilege IAM roles is recommended. For this internship challenge, static AWS credentials can be used in a short-lived test account when scoped appropriately.

## Infrastructure

All AWS infrastructure is provisioned with Terraform. No application infrastructure is created manually through the AWS console.

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

Copy the outputs into GitHub Actions secrets:

```text
tf_state_bucket -> TF_STATE_BUCKET
tf_lock_table   -> TF_LOCK_TABLE
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

## Architecture

Runtime traffic flow:

```text
Internet
  -> Application Load Balancer
  -> ECS Fargate service
  -> Node.js container on port 3000
```

Deployment flow:

```text
Developer push to feature branch
  -> GitHub Actions CI
  -> format check, lint, tests, Docker build, Trivy scan
  -> merge or push to main
  -> GitHub Actions CD
  -> Terraform provisions ECR
  -> Docker image is pushed to ECR
  -> Terraform provisions or updates AWS infrastructure
  -> ECS Fargate deploys the new task definition behind the ALB
```

## Visual Flow Diagram

The challenge requires a visual flow diagram created manually without AI generation.

Recommended tools:

- draw.io
- Excalidraw
- Eraser

The diagram should include the CI flow, CD flow, ECR image storage, Terraform-managed AWS infrastructure, Application Load Balancer, ECS Fargate service, auto scaling, CloudWatch logs, and the user traffic path. Use `docs/visual-diagram-checklist.md` as the checklist before exporting the final diagram into the `docs/` directory.

## Security and Reliability Notes

- The container runs as a non-root user.
- Trivy blocks images with HIGH or CRITICAL vulnerabilities when fixable issues are detected.
- ECR scan-on-push is enabled.
- ECS deployment circuit breaker is enabled with automatic rollback.
- Terraform state is stored remotely with locking.
- The ALB only accepts public HTTP traffic on port `80`.
- ECS tasks only accept application traffic from the ALB security group.

## Final Checklist

- [x] Public GitHub repository URL added to README
- [x] Dockerized Node.js application
- [x] Final Docker image size added to README
- [x] CI workflow for feature branches
- [x] CD workflow for deployment from `main`
- [x] Container registry through AWS ECR
- [x] AWS ECS Fargate deployment behind an Application Load Balancer
- [x] ECS auto scaling configured
- [x] Cloud infrastructure provisioned with Terraform
- [ ] Deployment link added after successful AWS deployment
- [ ] Manually created visual flow diagram exported into `docs/`
