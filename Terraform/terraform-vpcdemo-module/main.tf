terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.44.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "demo" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "${var.vpc_name}-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.demo.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.az

    tags = {
      Name = "${var.vpc_name}-public-subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.demo.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.az 

    tags = {
      Name = "${var.vpc_name}-private-subnet"
    }
}

resource "aws_internet_gateway" "demo_IGW" {
    vpc_id = aws_vpc.demo.id

    tags = {
      Name = "${var.vpc_name}-IGW"
    }
}
