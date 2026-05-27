provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "simple_ec2" {
    ami = "ami-07a00cf47dbbc844c"
    instance_type = "t2.micro"

    tags = {
        Name = "demo-1a"
    }
}