# Variables
variable "aws_access_key" {
  type = string
  description = "Enter User Access Key"
}

variable "aws_secret_key" {
  type = string
  description = "Enter User Secret Key"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type = string
  default = "login"
}

variable "public_subnet_cidrs" {
    type = map(string)
    default = {
        "frontend" = "10.0.0.0/24",
        "backend" = "10.0.1.0/24"
    }
}

variable "private_subnet_cidr" {
    type = string
    default = "10.0.2.0/24"
}

variable "web_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0" },  # SSH
    { port = 80, cidr = "0.0.0.0/0" }   # HTTP
  ]
}

variable "app_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0" },   # SSH
    { port = 8080, cidr = "0.0.0.0/0" }  # App-specific
  ]
}

# Variable for DB SG Ingress Ports
variable "db_ingress_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    { port = 22, cidr = "10.0.0.0/16" },   # SSH (restricted)
    { port = 5432, cidr = "10.0.0.0/16" }  # Postgres (restricted)
  ]
}

variable "common_egress_rule" {
  default = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 0
    ip_protocol = "tcp"
    to_port     = 65535
  }
}
