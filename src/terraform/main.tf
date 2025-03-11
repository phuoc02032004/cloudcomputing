provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_health_check_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_health_check_policy"
  description = "Policy for Lambda to access EC2 and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "health_check" {
  function_name = "health_check_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = "" # thay bằng S3 bucket name
  s3_key    = "lambda_function.zip"

  environment {
    variables = {
      VPS_URL            = "https://bpc-pos-admin-panel-api.nibies.space/health"
      TERRAFORM_S3_BUCKET = "your-terraform-bucket"
    }
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_launch_template" "spot_instance" {
  name_prefix   = "nestjs-spot-instance-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  # key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http.id]
  }

  user_data = <<-EOF
              #!/bin/bash
              docker run -d -p 3000:3000 nguyenybin2015/bpc-pos-admin-panel-api:latest
              EOF
}

resource "aws_spot_instance_request" "nestjs_spot" {
  launch_template {
    id      = aws_launch_template.spot_instance.id
    version = "$Latest"
  }

  wait_for_fulfillment = true
}

output "public_ip" {
  value = aws_spot_instance_request.nestjs_spot.public_ip
}