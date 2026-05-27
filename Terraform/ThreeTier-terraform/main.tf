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

resource "aws_vpc" "threetier" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

resource "aws_subnet" "pub-sub-1" {
    vpc_id = aws_vpc.threetier.id
    cidr_block = var.pub_sub_1_cidr
    availability_zone = var.az1
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.vpc_name}-pub-sub-1"
    }
}

resource "aws_subnet" "pub-sub-2" {
    vpc_id = aws_vpc.threetier.id
    cidr_block = var.pub_sub_2_cidr
    availability_zone = var.az2
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.vpc_name}-pub-sub-2"
    }
}

resource "aws_subnet" "pri-sub-1a" {
    vpc_id =aws_vpc.threetier.id
    cidr_block = var.pri_sub_1a_cidr
    availability_zone = var.az1

    tags = {
      Name = "${var.vpc_name}-pri-sub-1a"
    }
}

resource "aws_subnet" "pri-sub-1b" {
    vpc_id =aws_vpc.threetier.id
    cidr_block = var.pri_sub_1b_cidr
    availability_zone = var.az2

    tags = {
      Name = "${var.vpc_name}-pri-sub-1b"
    }
}

resource "aws_subnet" "pri-sub-2a" {
    vpc_id = aws_vpc.threetier.id
    cidr_block = var.pri_sub_2a_cidr
    availability_zone = var.az1

    tags = {
      Name = "${var.vpc_name}-pri-sub-2a"
    }
}

resource "aws_subnet" "pri-sub-2b" {
    vpc_id = aws_vpc.threetier.id
    cidr_block = var.pri_sub_2b_cidr
    availability_zone = var.az2

    tags = {
      Name = "${var.vpc_name}-pri-sub-2b"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.threetier.id

    tags = {
      Name = "${var.vpc_name}-IGW"
    }
}

resource "aws_eip" "nat-eip" {
    domain = "vpc"

    tags = {
      Name = "${var.vpc_name}-nat-eip"
    }
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.pub-sub-1.id

    depends_on = [ aws_internet_gateway.igw ]

    tags = {
      Name = "${var.vpc_name}-nat-gw"
    }
}


resource "aws_route_table" "pub-RT" {
    vpc_id = aws_vpc.threetier.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "${var.vpc_name}-pub-RT"
    }
}

resource "aws_route_table_association" "pub-sub-1-association" {
    subnet_id = aws_subnet.pub-sub-1.id
    route_table_id = aws_route_table.pub-RT.id
}

resource "aws_route_table_association" "pub-sub-2-association" {
    subnet_id = aws_subnet.pub-sub-2.id
    route_table_id = aws_route_table.pub-RT.id
}

resource "aws_route_table" "pri-RT-1" {
    vpc_id = aws_vpc.threetier.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gw.id
    }

    tags = {
      Name = "${var.vpc_name}-pri-RT-1"
    }
}

resource "aws_route_table_association" "pri-sub-1a-association" {
    subnet_id = aws_subnet.pri-sub-1a.id
    route_table_id = aws_route_table.pri-RT-1.id
}

resource "aws_route_table_association" "pri-sub-1b-association" {
    subnet_id = aws_subnet.pri-sub-1b.id
    route_table_id = aws_route_table.pri-RT-1.id
}

resource "aws_route_table" "pri-RT-2" {
    vpc_id = aws_vpc.threetier.id

    tags = {
      Name = "${var.vpc_name}-pri-RT-2"
    }
}

resource "aws_route_table_association" "pri-sub-2a-association" {
  subnet_id      = aws_subnet.pri-sub-2a.id
  route_table_id = aws_route_table.pri-RT-2.id
}

resource "aws_route_table_association" "pri-sub-2b-association" {
  subnet_id      = aws_subnet.pri-sub-2b.id
  route_table_id = aws_route_table.pri-RT-2.id
}

