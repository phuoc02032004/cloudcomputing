variable "aws_region" {
  description = "Region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 Spot instance"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID của AMI cho EC2 Spot instance"
  default     = "ami-12345678"
}

variable "spot_price" {
  description = "Giá tối đa của EC2 Spot instance"
  default     = "0.004" # giá trên 1 tiếng
}

variable "docker_image" {
  description = "Cái docker image trên docker hub để pull về" 
  default     = "nguyenybin2015/bpc-pos-admin-panel-api:latest"
}

variable "vps_url" {
  description = "link heathcheck"
  default     = "https://bpc-pos-admin-panel-api.nibies.space/health"
}

variable "terraform_s3_bucket" {
  description = "Bucket lưu terraform"
  default     = "" # thay bằng S3 bucket name
}

variable "github_token" {
  description = "GitHub token for triggering GitHub Actions"
  type        = string
}