output "ipv4" {
  value = aws_instance.grove.public_ip
}

output "ipv6" {
  value = aws_instance.grove.ipv6_addresses[0]
}
