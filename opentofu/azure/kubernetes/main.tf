data "azuread_client_config" "current" {}

resource "azurerm_role_assignment" "aks_rbac_cluster_admin" {
  for_each = var.aks_configs

  scope                = azurerm_resource_group.aks-rg[each.key].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azuread_client_config.current.client_id
}

resource "azurerm_resource_group" "aks-rg" {
  for_each = var.aks_configs

  name     = "${each.key}-aks-rg"
  location = each.value.location

  tags = each.value.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_configs

  location            = azurerm_resource_group.aks-rg[each.key].location
  resource_group_name = azurerm_resource_group.aks-rg[each.key].name

  name                = "${each.key}-aks"
  dns_prefix          = replace(each.key, "-", "")
  node_resource_group = "${azurerm_resource_group.aks-rg[each.key].name}-nodes"

  kubernetes_version = each.value.kubernetes_version

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = each.value.aad_role_based_access_control_enabled
    tenant_id          = each.value.aad_role_based_access_control_enabled ? data.azuread_client_config.current.tenant_id : ""
  }

  api_server_access_profile {
    authorized_ip_ranges = each.value.authorized_api_server_access_ip_ranges
  }

  network_profile {
    network_plugin = each.value.network_policy == "azure" ? "azure" : each.value.network_plugin
    network_policy = each.value.network_policy == "azure" ? "azure" : each.value.network_policy
  }

  default_node_pool {
    name                         = each.value.default_node_pool.name
    orchestrator_version         = each.value.kubernetes_version
    node_count                   = each.value.default_node_pool.node_count
    vm_size                      = each.value.default_node_pool.vm_size
    only_critical_addons_enabled = each.value.default_node_pool.only_critical_addons_enabled
    os_disk_size_gb              = each.value.default_node_pool.os_disk_size_gb
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(each.value.tags, {
    Environment = "Dev"
    }
  )

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
    ]
  }
}

#? Disable for pipeline
resource "null_resource" "get_aks_credentials" {
  for_each = var.get_kubeconfig_to_local ? var.aks_configs : {}

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
