## Project Zero Go Home

provider "azurerm" {
    features {}
    tenant_id = var.azure_tenant
    subscription_id = var.azure_subscription
    client_id = jsondecode(file(var.azure_credentials)).appId
    client_secret = jsondecode(file(var.azure_credentials)).password
}

# Create a resource group.  Most resources are attached to a resource group.
resource "azurerm_resource_group" "zero" {
    name = "zero-group"
    location = "eastus" #var.azure_location
}

resource "azurerm_virtual_network" "zero" {
    name = "zero-vnet"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location
    address_space = ["10.0.0.0/16", "${var.ULA48}:1::/64"]
}

resource "azurerm_subnet" "zero" {
    name = "zero-subnet"
    resource_group_name = azurerm_resource_group.zero.name
    virtual_network_name = azurerm_virtual_network.zero.name
    address_prefixes = azurerm_virtual_network.zero.address_space
}

resource "azurerm_public_ip" "zero-ipv4" {
    name = "zero-ipv4"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location
    ip_version = "IPv4"
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_public_ip" "zero-ipv6" {
    name = "zero-ipv6"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location
    ip_version = "IPv6"
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_network_security_group" "zero" {
    name = "zero-sg"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location

    security_rule {
        name = "zero-sg-ssh"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "zero" {
    name = "zero-if0"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location
    ip_configuration {
        name = "zero-if0-ipv4"
        primary = true
        subnet_id = azurerm_subnet.zero.id
        private_ip_address_version = "IPv4"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.zero-ipv4.id
    }
    ip_configuration {
        name = "zero-if0-ipv6"
        subnet_id = azurerm_subnet.zero.id
        private_ip_address_version = "IPv6"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.zero-ipv6.id
    }
}

resource "azurerm_network_interface_security_group_association" "zero" {
    network_interface_id = azurerm_network_interface.zero.id
    network_security_group_id = azurerm_network_security_group.zero.id
}

resource "azurerm_linux_virtual_machine" "zero" {
    name = "zero"
    resource_group_name = azurerm_resource_group.zero.name
    location = azurerm_resource_group.zero.location
    #size = "Standard_B1ms"
    #size = "Standard_H8_Promo"
    size = "Standard_D8ds_v4"
    network_interface_ids = [azurerm_network_interface.zero.id]

    disable_password_authentication = true
    admin_username = var.username
    admin_ssh_key {
        username = var.username
        public_key = var.ssh_public_key
    }

    os_disk {
        ## Network Disk
        #storage_account_type = "StandardSSD_LRS"
        #caching = "ReadWrite"

        ## Local disk
        storage_account_type = "Standard_LRS"
        caching = "ReadOnly"
        diff_disk_settings {
            option = "Local"
        }
    }

    # az vm image list --output table
    source_image_reference {
        publisher = "Debian"
        offer = "debian-10"
        version = "latest"
        sku = "10"
    }
}
