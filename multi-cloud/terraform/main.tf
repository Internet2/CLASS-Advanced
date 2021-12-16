## Project Zero Go Home

provider "azurerm" {
    features {}
    tenant_id = var.azure_tenant
    subscription_id = var.azure_subscription
    client_id = jsondecode(file(var.azure_credentials)).appId
    client_secret = jsondecode(file(var.azure_credentials)).password
}


module "gcp" {
    source = "./gcp"
    credentials = var.gcp_credentials
    project = var.gcp_project
    zone = var.gcp_zone
    username = var.username
    ssh_public_key = var.ssh_public_key
}

module "aws" {
    source = "./aws"
    credentials = var.aws_credentials
    region = var.aws_region
    username = var.username
    ssh_public_key = var.ssh_public_key
}
