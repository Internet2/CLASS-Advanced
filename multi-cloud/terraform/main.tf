## CLASS Advanced multi-cloud terraform

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
