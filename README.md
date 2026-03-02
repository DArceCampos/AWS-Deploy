# AWS ECS Web Project

A static web application containerized with Docker and deployed on AWS using ECS, Fargate, ECR, and Terraform.

## Architecture

- **ECR** - Stores the Docker image of the web application
- **ECS (Elastic Container Service)** – Orchestrates the deployment of containers, defining tasks and services.
- **Fargate** – Provides the serverless compute engine that runs the ECS tasks without managing EC2 instances.
- **VPC & Security Groups** - Handles networking and traffic rules
- **IAM Roles** - Manages permissions for ECS task execution
- **Terraform** - Provisions all AWS infrastructure as code

## Project Structure

```
aws-ecs-web/
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

## Deployment

### 1. Configure AWS credentials
```bash
aws configure
```

### 2. Build the Docker image
```bash
cd web
docker build -t ecs-web .
```

### 3. Provision infrastructure with Terraform
```bash
cd terraform
terraform init
terraform apply
```

### 4. Authenticate Docker with ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### 5. Tag and push the image to ECR
```bash
docker tag ecs-web:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/mini-ecs-web:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/mini-ecs-web:latest
```

### 6. Force ECS to deploy the new image
```bash
aws ecs update-service --cluster mini-cluster --service mini-service --force-new-deployment --region us-east-1
```

### 7. Get the public IP of the running task
```bash
# Get the task ARN
aws ecs list-tasks --cluster mini-cluster --region us-east-1

# Get the network interface ID
aws ecs describe-tasks --cluster mini-cluster --region us-east-1 --tasks <TASK_ID> --query "tasks[0].attachments[0].details" --output table

# Get the public IP
aws ec2 describe-network-interfaces --network-interface-ids <ENI_ID> --region us-east-1 --query "NetworkInterfaces[0].Association.PublicIp" --output text
```

Access the application at `http://<PUBLIC_IP>`

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
