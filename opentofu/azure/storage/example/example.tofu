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

module "storage" {
  source = "../"

  env              = "dev"
  location         = "malaysiawest"
  resource_postfix = "poc"
  tags             = { purpose = "poc" }

  storage_configs = {
    name                     = "pocstorage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    min_tls_version          = "TLS1_2"
  }

  file_shares = {
    "poc-files" = { quota_gb = 100 }
  }

  # Object IDs (`az ad signed-in-user show --query id -o tsv`) to grant data access
  role_assignment_principal_ids = []
}
