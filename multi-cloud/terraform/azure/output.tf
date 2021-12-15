output "ipv4" {
  value = azurerm_public_ip.zero-ipv4.ip_address
}

output "ipv6" {
  value = azurerm_public_ip.zero-ipv6.ip_address
}
