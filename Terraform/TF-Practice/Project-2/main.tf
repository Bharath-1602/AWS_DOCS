terraform {
  required_providers {
    aws = {
        source = "registry.terraform.io/hashicorp/aws"
        version = "6.44.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
      Name = "demo-vpc"
    }
}

resource "aws_subnet" "demo_subnet_1" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.subnet_cidr_1
    availability_zone = var.availability_zone

    tags = {
      Name = "demo_subnet_1"
    }
}

resource "aws_subnet" "demo_subnet_2" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.subnet_cidr_2
    availability_zone = var.availability_zone

    tags = {
      Name = "demo_subnet_2"
    }
  
}

resource "aws_internet_gateway" "demo-IGW" {
    vpc_id = aws_vpc.demo-vpc.id

    tags = {
      Name = "demo-IGW"
    }
}

resource "aws_security_group" "demo-SG" {
    name = "demo-SG"
    description = "seccurity group for demo"
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
        Name = "demo-SG"
    }
}

resource "aws_security_group_rule" "rule1" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [var.allowed_http]
    security_group_id = aws_security_group.demo-SG.id
}

resource "aws_security_group_rule" "rule2" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.demo-SG.id
}