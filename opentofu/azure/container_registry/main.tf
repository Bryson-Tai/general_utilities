resource "azurerm_resource_group" "acr-rg" {
  for_each = var.acr_configs

  name     = "${each.key}-acr-rg"
  location = each.value.location

  tags = each.value.tags
}

resource "azurerm_container_registry" "acr" {
  for_each = var.acr_configs

  location            = azurerm_resource_group.acr-rg[each.key].location
  resource_group_name = azurerm_resource_group.acr-rg[each.key].name

  name          = "${each.key}acr"
  sku           = "Basic"
  admin_enabled = false

  tags = merge(each.value.tags, {
    Environment = "Dev"
    }
  )
}
