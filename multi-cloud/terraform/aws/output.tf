output "ipv4" {
  value = aws_instance.zero.public_ip
}

output "ipv6" {
  value = aws_instance.zero.ipv6_addresses[0]
}
