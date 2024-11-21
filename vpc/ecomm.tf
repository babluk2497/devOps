# VPC 
resource "aws_vpc" "ecomm-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "ecomm-vpc"
  }
}

# Frontend Subnet
resource "aws_subnet" "ecomm-fe-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-frontend-subnet"
  }
}

# Backend Subnet
resource "aws_subnet" "ecomm-be-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-backend-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "ecomm-db-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "ecomm-pub-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "ecomm-pvt-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-private-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "ecomm-fe-asc" {
  subnet_id      = aws_subnet.ecomm-fe-sn.id
  route_table_id = aws_route_table.ecomm-pub-rt.id
}

# Public Route Table Association
resource "aws_route_table_association" "ecomm-be-asc" {
  subnet_id      = aws_subnet.ecomm-be-sn.id
  route_table_id = aws_route_table.ecomm-pub-rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "ecomm-db-asc" {
  subnet_id      = aws_subnet.ecomm-db-sn.id
  route_table_id = aws_route_table.ecomm-pvt-rt.id
}

# NACL
resource "aws_network_acl" "ecomm-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-nacl"
  }
}

# Frontend Security Group
resource "aws_security_group" "ecomm-fe-sg" {
  name        = "ecomm FE SG"
  description = "Allow Frontend traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-FE-SG"
  }
}

# Frontend SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-fe-sg-ing-ssh" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Frontend HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-fe-sg-ing-http" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Frontend Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-fe-sg-egg-all" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Backend Security Group
resource "aws_security_group" "ecomm-be-sg" {
  name        = "ecomm BE SG"
  description = "Allow Backend traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-BE-SG"
  }
}

# Backend SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-be-sg-ing-ssh" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Backend HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-be-sg-ing-http" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# Backend Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-be-sg-egg-all" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Database Security Group
resource "aws_security_group" "ecomm-db-sg" {
  name        = "ecomm DB SG"
  description = "Allow Database traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-DB-SG"
  }
}

# Database SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-ing-ssh" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Database POSTGRES Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-ing-postgres" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

# Database Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-db-sg-egg-all" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}