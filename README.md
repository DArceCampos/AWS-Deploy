# AWS ECS Web Project

A static web application containerized with Docker and deployed on AWS using ECS, Fargate, ECR, and Terraform.

## Architecture

- **ECR** - Stores the Docker image of the web application
- **ECS (Elastic Container Service)** - Orchestrates the deployment of containers, defining tasks and services
- **Fargate** - Provides the serverless compute engine that runs the ECS tasks without managing EC2 instances
- **VPC & Security Groups** - Handles networking and traffic rules
- **IAM Roles** - Manages permissions for ECS task execution
- **Terraform** - Provisions all AWS infrastructure as code
- **GitHub Actions** - Automates the build, push and deployment pipeline on every push to main

## CI/CD Pipeline

Every push to the `main` branch automatically triggers the following workflow:

```
Push to main
     |
     v
Checkout code
     |
     v
Configure AWS credentials
     |
     v
Login to Amazon ECR
     |
     v
Build & Push Docker image to ECR
     |
     v
Update ECS Task Definition
     |
     v
Deploy to ECS Fargate
```

## Project Structure

```
aws-ecs-web/
├── .github/
│   └── workflows/
│       └── deploy.yml    # GitHub Actions CI/CD pipeline
├── web/
│   ├── index.html        # Static web application
│   └── dockerfile        # Nginx container definition
└── terraform/
    ├── main.tf           # AWS infrastructure definition
    ├── variables.tf      # Input variables
    └── outputs.tf        # Output values
```

## Prerequisites

- [Docker](https://www.docker.com/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- AWS account with valid credentials
- GitHub repository with the following secrets configured:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key |

## Deployment

### First Time Setup

#### 1. Configure AWS credentials
```bash
aws configure
```

#### 2. Build the Docker image
```bash
cd web
docker build -t ecs-web .
```

#### 3. Provision infrastructure with Terraform
```bash
cd terraform
terraform init
terraform apply
```

#### 4. Authenticate Docker with ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

#### 5. Tag and push the image to ECR
```bash
docker tag ecs-web:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/mini-ecs-web:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/mini-ecs-web:latest
```

#### 6. Get the public IP of the running task
```bash
# Get the task ARN
aws ecs list-tasks --cluster mini-cluster --region us-east-1

# Get the network interface ID
aws ecs describe-tasks --cluster mini-cluster --region us-east-1 --tasks <TASK_ID> --query "tasks[0].attachments[0].details" --output table

# Get the public IP
aws ec2 describe-network-interfaces --network-interface-ids <ENI_ID> --region us-east-1 --query "NetworkInterfaces[0].Association.PublicIp" --output text
```

Access the application at `http://<PUBLIC_IP>`

### Subsequent Deployments (CI/CD)

After the first setup, any change pushed to `main` will automatically:

1. Build a new Docker image tagged with the commit SHA
2. Push the image to ECR
3. Update the ECS task definition with the new image
4. Deploy the updated task to Fargate

```bash
git add .
git commit -m "your changes"
git push origin main
```

Monitor the deployment in the **Actions** tab of your GitHub repository.

## Variables

| Variable | Description | Default |
|---|---|---|
| `region` | AWS region | `us-east-1` |
| `project_name` | Project name | `mini-ecs-web` |
| `cpu` | Fargate task CPU units | `256` |
| `memory` | Fargate task memory (MB) | `512` |

## Outputs

| Output | Description |
|---|---|
| `ecr_repository_url` | URL of the ECR repository |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_name` | Name of the ECS service |

## Cleanup

To destroy all AWS resources and avoid charges:
```bash
cd terraform
terraform destroy
```

