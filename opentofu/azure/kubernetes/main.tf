resource "azurerm_resource_group" "aks-rg" {
  for_each = var.aks_configs

  name     = "${length(each.value.resource_prefix) > 0 ? "${each.value.resource_prefix}-" : ""}${each.key}-rg"
  location = each.value.location

  tags = each.value.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_configs

  location            = azurerm_resource_group.aks-rg[each.key].location
  resource_group_name = azurerm_resource_group.aks-rg[each.key].name

  name                = "${length(each.value.resource_prefix) > 0 ? "${each.value.resource_prefix}-" : ""}${each.key}"
  dns_prefix          = replace(each.key, "-", "")
  node_resource_group = "${azurerm_resource_group.aks-rg[each.key].name}-nodes"

  default_node_pool {
    name                         = each.value.default_node_pool.name
    node_count                   = each.value.default_node_pool.node_count
    vm_size                      = each.value.default_node_pool.vm_size
    only_critical_addons_enabled = each.value.default_node_pool.only_critical_addons_enabled
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(each.value.tags, {
    Environment = "Dev"
    }
  )
}

resource "null_resource" "get_aks_credentials" {
  for_each = var.aks_configs

  provisioner "local-exec" {
    command = <<EOF
        az aks get-credentials \
        --overwrite-existing --admin \
        --resource-group ${azurerm_resource_group.aks-rg[each.key].name} \
        --name ${azurerm_kubernetes_cluster.aks[each.key].name} \
        --context ${azurerm_resource_group.aks-rg[each.key].name}
    EOF
  }
}
