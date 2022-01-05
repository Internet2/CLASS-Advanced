output "ipv4" {
  value = azurerm_public_ip.grove-ipv4.ip_address
}

output "ipv6" {
  value = azurerm_public_ip.grove-ipv6.ip_address
}
