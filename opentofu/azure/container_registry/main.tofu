resource "azurerm_resource_group" "acr-rg" {
  for_each = var.acr_configs

  name     = "${var.env}-${each.key}-acr-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_container_registry" "acr" {
  for_each = var.acr_configs

  location            = azurerm_resource_group.acr-rg[each.key].location
  resource_group_name = azurerm_resource_group.acr-rg[each.key].name

  name          = "${var.env}-${each.key}acr${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}"
  sku           = each.value.sku
  admin_enabled = each.value.admin_enabled

  tags = var.tags
}
