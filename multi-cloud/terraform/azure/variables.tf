variable "ULA48" {
    type = string
    # https://simpledns.plus/private-ipv6
    default = "fd06:3715:c284"
}

variable "credentials" {
    type = string
    default = "credentials.azure"
}

variable "location" {
    type = string
    default = "eastus"
}

variable "tenant" {
    type = string
}

variable "subscription" {
    type = string
}

variable "username" {
    type = string
}

variable "ssh_public_key" {
    type = string
}
