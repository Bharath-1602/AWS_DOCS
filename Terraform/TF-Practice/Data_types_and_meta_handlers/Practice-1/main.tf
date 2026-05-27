terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "6.44.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "demo_vpc"
  }
}

resource "aws_subnet" "demo_subnets" {
  count = length(var.azs)

  vpc_id = aws_vpc.demo_vpc.id

  cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index)

  availability_zone = var.azs[count.index]

  tags = {
    Name = var.subnet_names[count.index]
  }

}
