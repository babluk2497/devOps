# Server / Instance
resource "aws_instance" "login-web" {
  ami           = "ami-0b8c6b923777519db"
  instance_type = "t2.micro"
  key_name      = "2429"
  subnet_id     = aws_subnet.public_subnets.id
  vpc_security_group_ids = [aws_security_group.login-fe-sg.id]

  tags = {
    Name = "${var.vpc_name}-web-server"
  }
}