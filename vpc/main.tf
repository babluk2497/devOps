# VPC 
resource "aws_vpc" "login-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "login-vpc"
  }
}

# Frontend Subnet
resource "aws_subnet" "login-fe-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-frontend-subnet"
  }
}