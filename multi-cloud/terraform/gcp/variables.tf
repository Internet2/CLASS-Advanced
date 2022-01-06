variable "credentials" {
    type = string
    default = "credentials.gcp"
}

variable "project" {
    type = string
}

variable "zone" {
    type = string
    default = "us-east1-c"
}

variable "username" {
    type = string
}

variable "ssh_public_key" {
    type = string
}
