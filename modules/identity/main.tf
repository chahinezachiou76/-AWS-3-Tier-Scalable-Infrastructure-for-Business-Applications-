
# EC2 Assume Role Policy

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


# EC2 Role

resource "aws_iam_role" "ec2_role" {
  name               = "multi-az-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}


# Attach AWS Managed Policy (SSM)

resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Custom Policy (Secrets Manager + Logs)

data "aws_iam_policy_document" "ec2_custom_policy_doc" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_custom_policy" {
  name   = "multi-az-ec2-custom-policy"
  policy = data.aws_iam_policy_document.ec2_custom_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "custom_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_custom_policy.arn
}


# Instance Profile (Attach to EC2)

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "multi-az-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
