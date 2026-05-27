variable "aws_region" {
    type = string
    default = "ap-south-1"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_cidr_1" {
    type = string
    default = "10.0.1.0/24"
}

variable "subnet_cidr_2" {
    type = string
    default = "10.0.2.0/24"
}

variable "availability_zone" {
    type = string
    default = "ap-south-1a"
}

variable "allowed_http" {
    type = string
    default = "0.0.0.0/0"
}

