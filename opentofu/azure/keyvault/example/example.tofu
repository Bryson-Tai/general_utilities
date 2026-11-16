terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50" # module uses access_policy, removed in azurerm 5.x
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "<your-subscription-id>" # or export ARM_SUBSCRIPTION_ID
}

module "keyvault" {
  source = "../"

  env              = "dev"
  location         = "malaysiawest"
  resource_postfix = "poc"
  tags             = { purpose = "poc" }

  akv = {
    sku_name = "standard"
  }
}
