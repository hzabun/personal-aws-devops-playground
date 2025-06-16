resource "aws_iam_role" "demo_ecs_instance_role" {
  name = "demo-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "demo_ecs_instance_policy" {
  role       = aws_iam_role.demo_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "demo_ecs_instance_profile" {
  name = "demo-ecs-instance-profile"
  role = aws_iam_role.demo_ecs_instance_role.name
}

resource "aws_iam_role" "demo_ecs_task_execution_role" {
  name = "demo-ecs-task-execution-role"

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

resource "aws_iam_role_policy_attachment" "demo_ecs_task_execution_role_policy" {
  role       = aws_iam_role.demo_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "demo_ecs_task_execution_cloudwatch_policy" {
  role       = aws_iam_role.demo_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_policy.arn
}

resource "aws_iam_policy" "ecs_cloudwatch_policy" {
  name = "ecs-cloudwatch-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}