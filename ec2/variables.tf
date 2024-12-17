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

variable "public_subnet_cidr" {
  type = string
  default = "10.0.0.0/24"
}
