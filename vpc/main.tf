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

# Internet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "login-pub-rt" {
  vpc_id = aws_vpc.login-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "login-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "login-pvt-rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-private-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "login-fe-asc" {
  subnet_id      = aws_subnet.login-fe-sn.id
  route_table_id = aws_route_table.login-pub-rt.id
}

# Public Route Table Association
resource "aws_route_table_association" "login-be-asc" {
  subnet_id      = aws_subnet.login-be-sn.id
  route_table_id = aws_route_table.login-pub-rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "login-db-asc" {
  subnet_id      = aws_subnet.login-db-sn.id
  route_table_id = aws_route_table.login-pvt-rt.id
}

# NACL
resource "aws_network_acl" "login-nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "login-nacl"
  }
}

# Frontend Security Group
resource "aws_security_group" "login-fe-sg" {
  name        = "Login FE SG"
  description = "Allow Frontend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "Login-FE-SG"
  }
}

# Frontend SSH Rule
resource "aws_vpc_security_group_ingress_rule" "login-fe-sg-ing-ssh" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Frontend HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "login-fe-sg-ing-http" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Frontend Outbound
resource "aws_vpc_security_group_egress_rule" "login-fe-sg-egg-all" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Backend Security Group
resource "aws_security_group" "login-be-sg" {
  name        = "Login BE SG"
  description = "Allow Backend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "Login-BE-SG"
  }
}

# Backend SSH Rule
resource "aws_vpc_security_group_ingress_rule" "login-be-sg-ing-ssh" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Backend HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "login-be-sg-ing-http" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# Backend Outbound
resource "aws_vpc_security_group_egress_rule" "login-be-sg-egg-all" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Database Security Group
resource "aws_security_group" "login-db-sg" {
  name        = "Login DB SG"
  description = "Allow Database traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "Login-DB-SG"
  }
}

# Database SSH Rule
resource "aws_vpc_security_group_ingress_rule" "login-db-sg-ing-ssh" {
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Database POSTGRES Rule
resource "aws_vpc_security_group_ingress_rule" "login-db-sg-ing-postgres" {
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

# Database Outbound
resource "aws_vpc_security_group_egress_rule" "login-db-sg-egg-all" {
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}