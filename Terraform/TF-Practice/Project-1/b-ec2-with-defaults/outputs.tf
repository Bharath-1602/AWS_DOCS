output "aws_instance" {
  value = aws_instance.ec2_with_defaults.id
}

output "instance_public_ip" {
  value = aws_instance.ec2_with_defaults.public_ip
}

output "instance_arn" {
  value = aws_instance.ec2_with_defaults.arn
}