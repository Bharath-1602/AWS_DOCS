variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-07a00cf47dbbc844c"
}

variable "instance_name" {
  type    = string
  default = "EC2-WithDefaults"
}
