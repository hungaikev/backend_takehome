terraform {
  backend "s3" {
    bucket         = "my-ello-terraform-state-bucket"
    key            = "development/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "my-ello-terraform-locks"
    encrypt        = true
  }
}



provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "book-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "book-cluster"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

locals {
  container_definitions = jsonencode([
    {
      name      = "bookapp"
      image     = "731117654744.dkr.ecr.eu-central-1.amazonaws.com/my-ello-ecs-repository:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 4000
        hostPort      = 4000
      }],
      environment = [{
        name  = "NODE_ENV",
        value = "production"
      }],
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.ello_logs.name,
          "awslogs-region"        = "eu-central-1",
          "awslogs-stream-prefix" = "bookapp"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ello_logs" {
  name = "ello-cloudwatch-log-group"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "ello-task-family"
  container_definitions    = local.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ello-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_ecs_service" "app_service" {
  name            = "bookapp-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    assign_public_ip = true
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name   = "bookapp"
    container_port   = 4000
  }

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }

  depends_on = [aws_lb_listener.app_listener]
}

resource "aws_security_group" "service_sg" {
  name        = "bookapp-service-sg"
  description = "Security Group for BookApp ECS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}

resource "aws_lb" "app_load_balancer" {
  name               = "ello-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "ello-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
   target_type = "ip" 

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}


output "link_to_app" {
  value = "http://${aws_lb.app_load_balancer.dns_name}"
  
}
