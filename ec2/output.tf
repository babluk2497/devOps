
output "instance_ip" {
  value       = aws_instance.login-web.public_ip
  description = "EC2 Public IP"
}
