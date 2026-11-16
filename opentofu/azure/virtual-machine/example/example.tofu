terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.50.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "<your-subscription-id>" # or export ARM_SUBSCRIPTION_ID
}

# The module expects an existing resource group and virtual network
resource "azurerm_resource_group" "poc" {
  name     = "dev-vm-poc-rg"
  location = "malaysiawest"
  tags     = { purpose = "poc" }
}

resource "azurerm_virtual_network" "poc" {
  name                = "dev-vm-poc-vnet"
  location            = azurerm_resource_group.poc.location
  resource_group_name = azurerm_resource_group.poc.name
  address_space       = ["10.0.0.0/16"]
  tags                = { purpose = "poc" }
}

module "virtual_machine" {
  source = "../"

  group_name_prefix    = "poc"
  rg_name              = azurerm_resource_group.poc.name
  location             = azurerm_resource_group.poc.location
  virtual_network_name = azurerm_virtual_network.poc.name
  enable_sql_setup     = false

  vm_config = {
    web = {
      size               = "Standard_B2s"
      admin_username     = "adminuser"
      subnetName         = "web"
      app_sec_group_list = ["webserver"]
    }
  }

  subnet_config = {
    web = {
      subnet_ip_ranges = ["10.0.1.0/24"]

      security_rule_config = {
        allow-ssh = {
          priority                   = 100
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*" # restrict to your public IP /32 where possible
          destination_address_prefix = "*"
        }
      }
    }
  }
}
