data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "aks-rg" {
  for_each = var.aks_configs

  name     = "${var.env}-${each.key}-aks${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_configs

  location            = azurerm_resource_group.aks-rg[each.key].location
  resource_group_name = azurerm_resource_group.aks-rg[each.key].name

  name                = "${var.env}-${each.key}-aks${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}"
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

  node_provisioning_profile {
    default_node_pools = "None"
    mode               = "Manual"
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

  tags = merge(var.tags, {
    Environment = "Dev"
    }
  )

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  for_each = var.aks_configs

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[each.key].id

  name       = each.value.worker_node_pool.name
  vm_size    = each.value.worker_node_pool.vm_size
  os_type    = "Linux"
  os_sku     = each.value.worker_node_pool.os_sku
  node_count = each.value.worker_node_pool.node_count

  gpu_driver   = each.value.worker_node_pool.gpu_driver
  gpu_instance = each.value.worker_node_pool.gpu_instance

  tags = var.tags
}

#? Disable for pipeline
resource "terraform_data" "get_aks_credentials" {
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
