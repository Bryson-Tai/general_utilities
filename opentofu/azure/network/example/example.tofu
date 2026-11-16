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

module "network" {
  source = "../"

  env              = "dev"
  location         = "malaysiawest"
  resource_postfix = "poc"
  tags             = { purpose = "poc" }

  network = {
    address_space = ["10.0.0.0/16"]
    subnet = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}
