provider "aws" {
  region = var.aws_region
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

  s3_bucket = var.terraform_s3_bucket
  s3_key    = "lambda_function.zip"

  environment {
    variables = {
      VPS_URL            = var.vps_url
      TERRAFORM_S3_BUCKET = var.terraform_s3_bucket
    }
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # **CẢNH BÁO: Mở từ mọi nguồn IP, nên giới hạn nếu có thể**
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
  image_id      = var.ami_id  # Sử dụng var.ami_id đã được cập nhật thành Ubuntu AMI
  instance_type = var.instance_type
  key_name      = "phuocphuoc"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http.id]
  }

  # **USER DATA SCRIPT CHO UBUNTU (SỬ DỤNG APT-GET)**
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install docker.io -y
              systemctl start docker
              systemctl enable docker
              # docker run -d -p 3000:3000 ${var.docker_image} # Tạm thời comment để test cài Docker trước
              EOF
  )
}

resource "aws_spot_fleet_request" "nestjs_spot" {
  iam_fleet_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-ec2-spot-fleet-tagging-role"

  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.spot_instance.id
      version = "$Latest"
    }
  }

  spot_price         = var.spot_price
  target_capacity    = 1
  wait_for_fulfillment = true
}

data "aws_caller_identity" "current" {}

output "spot_instance_id" {
  value = aws_spot_fleet_request.nestjs_spot.id
}

output "lambda_function_name" {
  value = aws_lambda_function.health_check.function_name
}