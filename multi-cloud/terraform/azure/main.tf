## CLASS Advanced multi-cloud terraform azure

provider "azurerm" {
    features {}
    tenant_id = var.tenant
    subscription_id = var.subscription
    client_id = jsondecode(file(var.credentials)).appId
    client_secret = jsondecode(file(var.credentials)).password
}

# Create a resource group.  Most resources are attached to a resource group.
resource "azurerm_resource_group" "grove" {
    name = "grove-group"
    location = var.location
}

resource "azurerm_virtual_network" "grove" {
    name = "grove-vnet"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location
    address_space = ["10.0.0.0/16", "${var.ULA48}:1::/64"]
}

resource "azurerm_subnet" "grove" {
    name = "grove-subnet"
    resource_group_name = azurerm_resource_group.grove.name
    virtual_network_name = azurerm_virtual_network.grove.name
    address_prefixes = azurerm_virtual_network.grove.address_space
}

resource "azurerm_public_ip" "grove-ipv4" {
    name = "grove-ipv4"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location
    ip_version = "IPv4"
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_public_ip" "grove-ipv6" {
    name = "grove-ipv6"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location
    ip_version = "IPv6"
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_network_security_group" "grove" {
    name = "grove-sg"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location

    security_rule {
        name = "grove-sg-ssh"
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

resource "azurerm_network_interface" "grove" {
    name = "grove-if0"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location
    ip_configuration {
        name = "grove-if0-ipv4"
        primary = true
        subnet_id = azurerm_subnet.grove.id
        private_ip_address_version = "IPv4"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.grove-ipv4.id
    }
    ip_configuration {
        name = "grove-if0-ipv6"
        subnet_id = azurerm_subnet.grove.id
        private_ip_address_version = "IPv6"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.grove-ipv6.id
    }
}

resource "azurerm_network_interface_security_group_association" "grove" {
    network_interface_id = azurerm_network_interface.grove.id
    network_security_group_id = azurerm_network_security_group.grove.id
}

resource "azurerm_linux_virtual_machine" "grove" {
    name = "grove"
    resource_group_name = azurerm_resource_group.grove.name
    location = azurerm_resource_group.grove.location
    #size = "Standard_H8_Promo"
    #size = "Standard_D8ds_v4"
    size = "Standard_B1ms" # 2/2GiB
    network_interface_ids = [azurerm_network_interface.grove.id]

    disable_password_authentication = true
    admin_username = var.username
    admin_ssh_key {
        username = var.username
        public_key = var.ssh_public_key
    }

    os_disk {
        ## Network Disk
        storage_account_type = "StandardSSD_LRS"
        caching = "ReadWrite"

        ## Local disk
        #storage_account_type = "Standard_LRS"
        #caching = "ReadOnly"
        #diff_disk_settings {
        #    option = "Local"
        #}
    }

    # az vm image list --output table
    source_image_reference {
        publisher = "Debian"
        offer = "debian-11"
        version = "latest"
        sku = "11"
    }
}
