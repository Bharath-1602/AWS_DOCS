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

resource "aws_instance" "ec2_runtime" {
  ami = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = var.instance_name
  }

}

output "instance_details" {
  value = {
    instance_id  = aws_instance.ec2_runtime.id
    instance_ip  = aws_instance.ec2_runtime.public_ip
    instance_arn = aws_instance.ec2_runtime.arn
  }
}