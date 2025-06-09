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