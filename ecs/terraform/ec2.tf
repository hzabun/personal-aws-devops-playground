data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

resource "aws_launch_template" "flask_instances" {
  name_prefix            = "ecs-flask-instance-"
  image_id               = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ecs_flask_task_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.demo_ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
            EOF
  )

  tags = merge(local.tags, {
    Name = "flask_instance"
  })
}

resource "aws_autoscaling_group" "ecs_flask_asg" {
  vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  desired_capacity    = 3
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.flask_instances.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "ecs_flask_task_sg" {
  name        = "ecs-flask-sg"
  description = "Allow inbound traffic to Flask app"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [ aws_security_group.ecs_flask_lb_sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_flask_lb_sg" {
  name = "ecs-flask-alb-sg"
  description = "Allow inbound traffic to flask ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs_flask_alb" {
  name               = "ecs-flask-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups = [ aws_security_group.ecs_flask_lb_sg.id]

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_target_group" "ecs_flask_alb_target_group" {
  name     = "ecs-flask-alb-target-group"
  port     = 5000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "ecs_flask_alb_listener" {
  load_balancer_arn = aws_lb.ecs_flask_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_flask_alb_target_group.arn
  }
}