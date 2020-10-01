# Create a resource group
resource "azurerm_resource_group" "thoughtworks-iac-rg" {
    name     = "TW-Terraform"
    location = "westeurope"
}

# Create VNET
resource "azurerm_virtual_network" "thoughtworks-iac-network" {
    name                = "tw-iac-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.thoughtworks-iac-rg.name

}

# Create subnet
resource "azurerm_subnet" "thoughtworks-iac-subnet" {
    name                 = "tw-iac-subnet"
    resource_group_name  = azurerm_resource_group.thoughtworks-iac-rg.name
    virtual_network_name = azurerm_virtual_network.thoughtworks-iac-network.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create PIP
resource "azurerm_public_ip" "thoughtworks-iac-pip" {
    name                         = "tw-iac-pip"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.thoughtworks-iac-rg.name
    allocation_method            = "Static"
}

# Create NSG
resource "azurerm_network_security_group" "thoughtworks-iac-nsg" {
    name                = "tw-iac-nsg"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.thoughtworks-iac-rg.name

    security_rule {
        name                       = "AllowPort80"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "AllowSSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "thoughtworks-iac-nic" {
    name                      = "tw-iac-nic"
    location                  = "westeurope"
    resource_group_name       = azurerm_resource_group.thoughtworks-iac-rg.name

    ip_configuration {
        name                          = "twNicConfiguration"
        subnet_id                     = azurerm_subnet.thoughtworks-iac-subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.1.10"
        public_ip_address_id          = azurerm_public_ip.thoughtworks-iac-pip.id
    }
}

# Connect security group and network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.thoughtworks-iac-nic.id
    network_security_group_id = azurerm_network_security_group.thoughtworks-iac-nsg.id
}

# Create VM
resource "azurerm_linux_virtual_machine" "thoughtworks-iac-vm" {
    name                  = "tw-iac"
    location              = "westeurope"
    resource_group_name   = azurerm_resource_group.thoughtworks-iac-rg.name
    network_interface_ids = [azurerm_network_interface.thoughtworks-iac-nic.id]
    size                  = "Standard_D2s_v3"

    os_disk {
        name              = "tw-iac-disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb    = "200"
    }

    source_image_reference {
        publisher = "Debian"
        offer     = "debian-10"
        sku       = "10"
        version   = "latest"
    }

    computer_name  = "tw-iac"
    admin_username = "azureuser"
    disable_password_authentication = true
        
    admin_ssh_key {
        username       = "azureuser"
        public_key     = file("id_rsa.pub")
    }

# Copy automation script from local to Azure VM
  provisioner "file" {
    source      = "automation.sh"
    destination = "$HOME/automation.sh"
     connection {
      type     = "ssh"
      host     = azurerm_public_ip.thoughtworks-iac-pip.ip_address
      user     = azurerm_linux_virtual_machine.thoughtworks-iac-vm.admin_username
      private_key = file("id_rsa")
    }
  }

# Run script and hand over variables
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/automation.sh",
      "$HOME/automation.sh"
    ]
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.thoughtworks-iac-pip.ip_address
      user     = azurerm_linux_virtual_machine.thoughtworks-iac-vm.admin_username
      private_key = file("id_rsa")
    }
  } 
}

# Making it easier for the user
output "thoughtworks-pip" {
  value = azurerm_public_ip.thoughtworks-iac-pip.ip_address
}