#VPC
resource "aws_vpc" "login-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "login-vpc"
  }
}

resource "aws_subnet" "login-fe-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "login-fe-subnet"
  }
}