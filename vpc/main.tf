# VPC 
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Frontend Subnet
resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.vpc.id
  for_each   = var.public_subnet_cidrs
  cidr_block = each.value
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "login-db-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.vpc_name}-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "login-pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "login-pvt-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "login-fe-asc" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.login-pub-rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "login-db-asc" {
  subnet_id      = aws_subnet.login-db-sn.id
  route_table_id = aws_route_table.login-pvt-rt.id
}

# NACL
resource "aws_network_acl" "login-nacl" {
  vpc_id = aws_vpc.vpc.id

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
    Name = "${var.vpc_name}-nacl"
  }
}

# Frontend Security Group
resource "aws_security_group" "login-fe-sg" {
  name        = "Login FE SG"
  description = "Allow Frontend traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-FE-SG"
  }
}

# Frontend Rules
resource "aws_vpc_security_group_ingress_rule" "login_web_ingress" {
  count             = length(var.web_ingress_ports)
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = var.web_ingress_ports[count.index].cidr
  from_port         = var.web_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.web_ingress_ports[count.index].port
}

# Backend Security Group
resource "aws_security_group" "login-be-sg" {
  name        = "Login BE SG"
  description = "Allow Backend traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-BE-SG"
  }
}

# Backend Rule
resource "aws_vpc_security_group_ingress_rule" "login_app_ingress" {
  count             = length(var.app_ingress_ports)
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = var.app_ingress_ports[count.index].cidr
  from_port         = var.app_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.app_ingress_ports[count.index].port
}

# Database Security Group
resource "aws_security_group" "login-db-sg" {
  name        = "Login DB SG"
  description = "Allow Database traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-DB-SG"
  }
}

# Database Rules
resource "aws_vpc_security_group_ingress_rule" "login_db_ingress" {
  count             = length(var.db_ingress_ports)
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = var.db_ingress_ports[count.index].cidr
  from_port         = var.db_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.db_ingress_ports[count.index].port
}


locals {
  security_groups = {
    "web" = aws_security_group.login-fe-sg.id
    "app" = aws_security_group.login-be-sg.id
    "db"  = aws_security_group.login-db-sg.id
  }
}

resource "aws_vpc_security_group_egress_rule" "common_egress" {
  for_each    = local.security_groups
  security_group_id = each.value
  cidr_ipv4   = var.common_egress_rule.cidr_ipv4
  from_port   = var.common_egress_rule.from_port
  ip_protocol = var.common_egress_rule.ip_protocol
  to_port     = var.common_egress_rule.to_port
}