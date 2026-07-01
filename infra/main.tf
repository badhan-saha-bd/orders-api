terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for the service security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ECS service."
  type        = list(string)
}

variable "container_image" {
  description = "Orders API container image to run."
  type        = string
}

variable "allowed_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to call the API."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "secret_key_parameter_arn" {
  description = "Secrets Manager secret or SSM Parameter ARN containing the Flask secret key."
  type        = string
  sensitive   = true
}

locals {
  name           = "orders-api"
  container_port = 5000
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${local.name}"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "api" {
  name = "${local.name}-cluster"
}

resource "aws_iam_role" "task_execution" {
  name = "${local.name}-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "api" {
  name        = "${local.name}-sg"
  description = "Allow API traffic to the orders service"
  vpc_id      = var.vpc_id

  ingress {
    description = "Orders API"
    from_port   = local.container_port
    to_port     = local.container_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  egress {
    description = "Allow outbound HTTPS for image pulls and AWS APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "APP_ENV"
          value = "production"
        }
      ]
      secrets = [
        {
          name      = "SECRET_KEY"
          valueFrom = var.secret_key_parameter_arn
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "python -c \"import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/healthz', timeout=2).read()\""
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      readonlyRootFilesystem = true
      linuxParameters = {
        initProcessEnabled = true
      }
      user = "1000"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = local.name
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  name            = local.name
  cluster         = aws_ecs_cluster.api.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.api.id]
    assign_public_ip = false
  }
}
