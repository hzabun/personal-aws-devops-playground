resource "aws_iam_instance_profile" "ecr_pull_profile" {
  name = "ecr-pull-profile"
  role = aws_iam_role.ec2_ecr_pull_role.name
}

resource "aws_iam_role" "ec2_ecr_pull_role" {
  name = "ec2-ecr-pull-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "ecr_pull" {
  name   = "ecr-pull"
  role   = aws_iam_role.ec2_ecr_pull_role.id
  policy = data.aws_iam_policy_document.ecr_pull.json
}


data "aws_iam_policy_document" "ecr_pull" {
  statement {
    sid = "1"

    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:ListImages"
    ]
    resources = ["*"]
  }
}