# Hướng dẫn sử dụng Terraform để tạo EC2 Spot instance chạy Docker chứa ứng dụng NestJS

## Mục lục
1. [Giới thiệu](#giới-thiệu)
2. [Yêu cầu](#yêu-cầu)
3. [Cài đặt Terraform](#cài-đặt-terraform)
4. [Triển khai EC2 Spot instance](#triển-khai-ec2-spot-instance)
5. [Kiểm tra sức khỏe ứng dụng](#kiểm-tra-sức-khỏe-ứng-dụng)
6. [Auto-Healing với AWS Lambda](#auto-healing-với-aws-lambda)
7. [Tích hợp CI/CD](#tích-hợp-cicd)

## Giới thiệu
Hướng dẫn này sẽ giúp bạn sử dụng Terraform để tạo một EC2 Spot instance chạy Docker chứa ứng dụng NestJS. Ứng dụng này cung cấp endpoint kiểm tra sức khỏe (health-check) tại `https://bpc-pos-admin-panel-api.nibies.space/health` với kết quả trả về dạng JSON.

## Yêu cầu
- Tài khoản AWS
- Cài đặt Terraform
- Cài đặt Docker
- Kiến thức cơ bản về NestJS và CI/CD

## Cài đặt Terraform
1. Tải và cài đặt Terraform từ [trang chủ Terraform](https://www.terraform.io/downloads.html).
2. Kiểm tra phiên bản Terraform đã cài đặt:
  ```sh
  terraform -v
  ```

## Triển khai EC2 Spot instance
1. Tạo file cấu hình Terraform `main.tf`:
  ```hcl
  provider "aws" {
    region = "us-west-2"
  }

  resource "aws_instance" "example" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    spot_price    = "0.004"
    user_data     = <<-EOF
            #!/bin/bash
            docker run -d -p 3000:3000 nguyenybin2015/bpc-pos-admin-panel-api:latest
            EOF
  }
  ```

2. Triển khai Terraform:
  ```sh
  terraform init
  terraform apply
  ```

## Kiểm tra sức khỏe ứng dụng
Lambda sử dụng lệnh sau để kiểm tra sức khỏe của ứng dụng NestJS:
```sh
curl -X 'GET' 'https://bpc-pos-admin-panel-api.nibies.space/health' -H 'accept: application/json'
```

## Auto-Healing với AWS Lambda
1. Tạo AWS Lambda function với các bước sau:
  - Health Check: Kiểm tra sức khỏe của ứng dụng.
  - Phân tích kết quả: Xác định trạng thái của các service quan trọng.
  - Auto-Healing: Xoá EC2 Spot instance cũ và tạo mới một instance.

2. Mã Lambda function mẫu:
  ```python
  import json
  import subprocess
  import boto3

  def lambda_handler(event, context):
    try:
      response = subprocess.check_output(['curl', '-X', 'GET', 'https://bpc-pos-admin-panel-api.nibies.space/health', '-H', 'accept: application/json'])
      health_status = json.loads(response)
      if health_status['info']['search-service-health']['status'] == 'down':
        trigger_auto_healing()
    except Exception as e:
      trigger_auto_healing()

  def trigger_auto_healing():
    # Xoá EC2 Spot instance cũ và tạo mới
    pass
  ```

2. Khi Lambda trigger auto-healing, CI/CD sẽ được kích hoạt lại để deploy source code lên instance mới.

##hướng dẫn:
cd terraform-test
terraform init
terraform plan
terraform apply

để tắt:
aws ec2 describe-spot-fleet-requests --query "SpotFleetRequestConfigs[*].SpotFleetRequestId"

lấy id đó bỏ vào đây:
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids sfr-đâyđây --terminate-instances