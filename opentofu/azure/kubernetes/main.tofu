data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "aks-rg" {
  name     = "${var.env}-${var.aks_configs.name}-aks${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}-rg"
  location = var.location

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name

  name                = "${var.env}-${var.aks_configs.name}-aks${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}"
  dns_prefix          = replace(var.aks_configs.name, "-", "")
  node_resource_group = "${azurerm_resource_group.aks-rg.name}-nodes"

  kubernetes_version = var.aks_configs.kubernetes_version

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = var.aks_configs.aad_role_based_access_control_enabled
    tenant_id          = var.aks_configs.aad_role_based_access_control_enabled ? data.azuread_client_config.current.tenant_id : ""
  }

  api_server_access_profile {
    authorized_ip_ranges = var.aks_configs.authorized_api_server_access_ip_ranges
  }

  network_profile {
    network_plugin = var.aks_configs.network_policy == "azure" ? "azure" : var.aks_configs.network_plugin
    network_policy = var.aks_configs.network_policy == "azure" ? "azure" : var.aks_configs.network_policy
  }

  node_provisioning_profile {
    default_node_pools = "None"
    mode               = "Manual"
  }

  default_node_pool {
    name                         = var.aks_configs.default_node_pool.name
    orchestrator_version         = var.aks_configs.kubernetes_version
    node_count                   = var.aks_configs.default_node_pool.node_count
    vm_size                      = var.aks_configs.default_node_pool.vm_size
    only_critical_addons_enabled = var.aks_configs.default_node_pool.only_critical_addons_enabled
    os_disk_size_gb              = var.aks_configs.default_node_pool.os_disk_size_gb

    upgrade_settings {
      drain_timeout_in_minutes      = var.aks_configs.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      max_surge                     = var.aks_configs.default_node_pool.upgrade_settings.max_surge
      node_soak_duration_in_minutes = var.aks_configs.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
    }
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
      tags
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  for_each = var.worker_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  name        = each.key
  vm_size     = each.value.vm_size
  os_type     = "Linux"
  os_sku      = each.value.os_sku
  node_count  = each.value.node_count
  node_taints = each.value.node_taints

  gpu_driver   = each.value.gpu_driver
  gpu_instance = each.value.gpu_instance

  upgrade_settings {
    drain_timeout_in_minutes      = each.value.upgrade_settings.drain_timeout_in_minutes
    max_surge                     = each.value.upgrade_settings.max_surge
    node_soak_duration_in_minutes = each.value.upgrade_settings.node_soak_duration_in_minutes
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#? Disable for pipeline
resource "terraform_data" "get_aks_credentials" {
  count = var.get_kubeconfig_to_local ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
        az aks get-credentials \
        --overwrite-existing \
        --admin \
        --resource-group ${azurerm_resource_group.aks-rg.name} \
        --name ${azurerm_kubernetes_cluster.aks.name} \
        --context ${azurerm_kubernetes_cluster.aks.name}
    EOF
  }
}

resource "terraform_data" "install_gpu" {
  for_each = { for k, v in var.worker_node_pools : k => v if v.gpu_driver == "Install" }

  provisioner "local-exec" {
    command = templatefile("${path.module}/bash/helm-deploy-gpu-operator.sh", {
      KUBE_CONTEXT = azurerm_kubernetes_cluster.aks.name
      CURRENT_DIR  = "${path.module}"
    })
  }
}
