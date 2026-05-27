output "vpc_id" {
    value = aws_vpc.demo-vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.demo-vpc.cidr_block
}

output "subnet_id" {
    value = aws_subnet.demo_subnet_1.id
}

output "subnet_cidr" {
    value = aws_subnet.demo_subnet_1.cidr_block
}
output "internet_gateway_id" {
    value = aws_internet_gateway.demo-IGW.id
}