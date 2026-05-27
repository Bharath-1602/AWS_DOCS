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

resource "aws_instance" "ec2_with_tfvars" {
  ami = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
    Environment = var.environment
  }
}

output "instance_id" {
  value = aws_instance.ec2_with_tfvars.id
}

output "instance_public_ip" {
  value = aws_instance.ec2_with_tfvars.public_ip
}