output "ipv4" {
    value = google_compute_address.zero.address
}

output "ipv6" {
    value = null
}