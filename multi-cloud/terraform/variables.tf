variable "aws_credentials" {
    type = string
    default = "../../secrets/credentials.aws"
} 

variable "azure_credentials" {
    type = string
    default = "../../secrets/credentials.azure"
}

variable "gcp_credentials" {
    type = string
    default = "../../secrets/credentials.gcp"
}

variable "username" {
    type = string
}
variable "ssh_public_key" {
    type = string
}

variable "aws_region" {
    type = string
}

variable "azure_tenant" {
    type = string
}

variable "azure_subscription" {
    type = string
}

variable "gcp_project" {
    type = string
}

variable "gcp_zone" {
    type = string
}
