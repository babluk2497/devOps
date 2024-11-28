variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "vpc_name" {
    description = "CIDR block for the vpc"
    type        = string 
}

variable "public-subnet_cidr" {
    description = "CIDR block for the public subnet"
    type        = string
}

variable "availability_zone" {
    description = "Availability zone for the public subnet"
    type        = string
}

