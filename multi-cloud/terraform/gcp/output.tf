output "ipv4" {
    value = google_compute_address.grove.address
}

output "ipv6" {
    value = null
}