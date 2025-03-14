variable "aws_region" {
  description = "Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Spot instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID của AMI cho EC2 Spot instance"
  default     = "ami-04b4f1a9cf54c11d0" 
}

variable "spot_price" {
  description = "Giá tối đa của EC2 Spot instance"
  default     = "0.004"
}

variable "docker_image" {
  description = "Docker image trên Docker Hub để pull về"
  default     = "nguyenybin2015/bpc-pos-admin-panel-api:latest"
}

variable "vps_url" {
  description = "Link healthcheck của ứng dụng"
  default     = "https://bpc-pos-admin-panel-api.nibies.space/health"
}

variable "terraform_s3_bucket" {
  description = "Tên bucket S3 để lưu trữ Terraform state hoặc function Lambda"
  type        = string
  default     = "cloud-dammay"
}
