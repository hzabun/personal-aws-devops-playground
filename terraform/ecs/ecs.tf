resource "aws_ecs_cluster" "flask_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "flask_capacity_group" {
  name = "flask-capacity-group"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_flask_asg.arn
    managed_scaling {
      status = "ENABLED"
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "flask_cluster_capacity" {
  cluster_name = aws_ecs_cluster.flask_cluster.name
  capacity_providers = [ aws_ecs_capacity_provider.flask_capacity_group.name ]
}