terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.50.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "<your-subscription-id>" # or export ARM_SUBSCRIPTION_ID
}

provider "azuread" {}

module "kubernetes" {
  source = "../"

  env              = "dev"
  location         = "malaysiawest"
  resource_postfix = "poc"
  tags             = { purpose = "poc" }

  get_kubeconfig_to_local = false

  aks_configs = {
    name = "poc"
    # Check supported versions: az aks get-versions -l malaysiawest -o table
    kubernetes_version                     = "1.33.0"
    aad_role_based_access_control_enabled  = false
    authorized_api_server_access_ip_ranges = ["0.0.0.0/0"] # restrict to your public IP /32 where possible
    network_plugin                         = "azure"
    network_policy                         = "azure"

    default_node_pool = {
      name                         = "system"
      vm_size                      = "Standard_D2s_v3"
      node_count                   = 1
      only_critical_addons_enabled = false
      os_disk_size_gb              = 64
      upgrade_settings = {
        max_surge = "10%"
      }
    }
  }

  worker_node_pools = {
    # Small CPU-only worker pool (no GPU)
    "cpuworker1" = {
      vm_size         = "Standard_D2s_v3"
      node_count      = 1
      node_taints     = []
      os_disk_size_gb = 64
      gpu_driver      = "None"
      gpu_instance    = null
      upgrade_settings = {
        max_surge = "10%"
      }
    },

    # With GPU
    # "gpuworker1" = {
    #   vm_size         = "Standard_NC4as_T4_v3"
    #   os_sku          = "Ubuntu"
    #   node_count      = 1
    #   os_disk_size_gb = 32

    #   node_taints = [
    #     "sku=gpu:NoSchedule"
    #   ]

    #   upgrade_settings = {
    #     max_surge                     = "20%"
    #     drain_timeout_in_minutes      = 30
    #     node_soak_duration_in_minutes = 30
    #   }

    #   gpu_driver = "Install"
    #   #TODO: Selected Instance doesn't support MIG, try single GPU instance
    #   # gpu_instance = "MIG1g"
    # }
  }
}
