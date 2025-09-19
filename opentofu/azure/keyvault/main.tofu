data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-akv${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "akv" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  name     = "${var.env}-akv${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}"
  sku_name = var.akv.sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
