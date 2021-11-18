terraform {
  
  required_providers {
    azurerm = "2.52.0"
  }
  
  backend "azurerm" {
    resource_group_name  = "RG-Terraform"
    storage_account_name = "jonwterraformstorage"
    container_name       = "terraformstate"
    key                  = "UcxyiThFntiiF/cqXUruyrNiOApgsNjq2dTaEHk2cghtWot5TceJRoDiIEgzNJuzJYAbK6nO/3n14IJVOaH62Q=="
  }

}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
data "azurerm_client_config" "current" {}

# Create our Resource Group - RG-Terraform
resource "azurerm_resource_group" "rg" {
  name     = "RG-AzureDevOps1"
  location = "West US 2"
}

# Create our Virtual Network - VNet-AzureDevOps1
resource "azurerm_virtual_network" "vnet" {
  name                = "VNet-AzureDevOps1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create our Subnet to hold our VM - Subnet-AzureDevOps1
resource "azurerm_subnet" "sn" {
  name                 = "Subnet-AzureDevOps1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create our Azure Storage Account - saazuredevops1
resource "azurerm_storage_account" "sa" {
  name                     = "saazuredevops1"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "azuredevops1"
  }
}

# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "NIC-AzureDevOps1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create our Virtual Machine - VM-AzureDevOps1
resource "azurerm_virtual_machine" "vm" {
  name                  = "VM-AzureDevOps1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_B2s"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "OSDisk-AzureDevOps1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM-AzureDevOps1"
    admin_username = "pejastojakovic"
    admin_password = "zaq1@WSXcde3"
  }
  os_profile_windows_config {
  }
}
