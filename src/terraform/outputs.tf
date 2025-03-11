output "spot_instance_public_ip" {
  value = aws_instance.nestjs_spot_instance.public_ip
}

output "spot_instance_id" {
  value = aws_instance.nestjs_spot_instance.id
}

output "lambda_function_name" {
  value = aws_lambda_function.health_check_function.function_name
}