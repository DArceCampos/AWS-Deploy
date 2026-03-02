variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  default     = "mini-ecs-web"
}

variable "cpu" {
  default = "256"
}

variable "memory" {
  default = "512"
}