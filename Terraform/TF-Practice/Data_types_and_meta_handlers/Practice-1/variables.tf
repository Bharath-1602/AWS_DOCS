variable "aws_region" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_names" {
  type = list(string)
}
