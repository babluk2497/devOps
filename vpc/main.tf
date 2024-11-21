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

# Backend Subnet
resource "aws_subnet" "login-be-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-backend-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "login-db-sn" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "login-database-subnet"
  }
}