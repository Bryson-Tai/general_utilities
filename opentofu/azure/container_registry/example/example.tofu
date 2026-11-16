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

module "container_registry" {
  source = "../"

  env              = "dev"
  location         = "malaysiawest"
  resource_postfix = "poc"
  tags             = { purpose = "poc" }

  acr_configs = {
    poc = {
      sku           = "Basic"
      admin_enabled = false
    }
  }
}
