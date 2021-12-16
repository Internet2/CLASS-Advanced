## Project Zero Go Home

provider "aws" {
  region = var.aws_region
  shared_credentials_file = var.aws_credentials
}

provider "azurerm" {
    features {}
    tenant_id = var.azure_tenant
    subscription_id = var.azure_subscription
    client_id = jsondecode(file(var.azure_credentials)).appId
    client_secret = jsondecode(file(var.azure_credentials)).password
}

provider "google" {
    project = var.gcp_project
    credentials = file(var.gcp_credentials_file)
}

module "gcp" {
    source = "./gcp"
    project = var.gcp_project
    zone = var.gcp_zone
    username = var.username
    ssh_public_key = var.ssh_public_key
}
