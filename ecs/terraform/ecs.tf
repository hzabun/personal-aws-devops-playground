resource "aws_ecs_cluster" "flask_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "flask_asg_capacity_group" {
  name = "flask-capacity-group"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_flask_asg.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "flask_cluster_capacity" {
  cluster_name       = aws_ecs_cluster.flask_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.flask_asg_capacity_group.name]
}

resource "aws_ecs_task_definition" "flask_task_definition" {
  family             = "flask-app"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.demo_ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "flask-app"
      image     = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.namespace}/${var.repo}:${var.image_tag}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-flask",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "awslogs-example"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "flask_service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.flask_cluster.id
  task_definition = aws_ecs_task_definition.flask_task_definition.arn
  desired_count   = 3
  network_configuration {
    subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    security_groups = [aws_security_group.ecs_flask_task_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_flask_alb_target_group.arn
    container_name   = "flask-app"
    container_port   = 5000
  }
}