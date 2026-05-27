terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "demo-ec2" {
    ami = var.ami_id
    instance_type = var.instance_type
}
