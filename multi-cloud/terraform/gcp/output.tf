output "ipv4" {
    value = google_compute_address.grove_ipv4.address
}

output "ipv6" {
    # borken
    value = null # google_compute_instance.grove.network_interface[0].ipv6_access_config[0].external_ipv6
}