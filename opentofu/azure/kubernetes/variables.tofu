variable "env" {
  type = string
}

variable "tags" {
  description = "The tags for assign to each of the available resources"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "The location (region) of deployment"
  type        = string
}

variable "resource_postfix" {
  description = "Add name postfix into Azure resource name"
  type = string
  default = ""
}

variable "aks_configs" {
  description = <<EOF
    The configuration for the Azure Kubernetes Service (AKS) cluster.

    location                               : The Azure region where the AKS cluster will be created.
    kubernetes_version                     : The version of Kubernetes to use, default is "1.33.0".
    aad_role_based_access_control_enabled  : Whether to enable role-based access control, set this to true will also set `azure_active_directory_role_based_access_control.azure_rbac_enabled` to true, default is true.
    authorized_api_server_access_ip_ranges : A list of IP ranges that are allowed to access the Kubernetes API server.
    network_policy                         : The network policy to use, can be "azure", "cilium" or "calico", default is "azure".
    network_plugin                         : The network plugin to use, can be "azure", "kubenet" or "none", default is "azure".
    default_node_pool                      : Configuration for the default node pool, including:
      - name                          : Name of the node pool.
      - vm_size                       : Size of the virtual machines in the node pool.
      - node_count                    : Number of nodes in the node pool, default is 1.
      - only_critical_addons_enabled  : Whether to enable only critical addons, default is false.
      - os_disk_size_gb               : Size of the OS disk in GB, default is 32.
    tags                                   : A map of tags to apply to the AKS cluster.
  EOF

  type = map(object({
    kubernetes_version                     = optional(string, "1.33.0")
    aad_role_based_access_control_enabled  = optional(bool, false)
    authorized_api_server_access_ip_ranges = optional(list(string), ["0.0.0.0/0"])
    network_plugin                         = optional(string, "azure")
    network_policy                         = optional(string, "azure")
    default_node_pool = object({
      name                         = string
      vm_size                      = string
      node_count                   = optional(number, 1)
      only_critical_addons_enabled = optional(bool, false)
      os_disk_size_gb              = optional(number, 32)
    })
  }))

  default = {
    example = {
      kubernetes_version = "1.33.0"
      aad_role_based_access_control_enabled = true
      authorized_api_server_access_ip_ranges = ["0.0.0/0"]
      network_plugin     = "azure"
      network_policy     = "azure"
      default_node_pool = {
        name                         = "default"
        vm_size                      = "Standard_D2_v2"
        node_count                   = 1
        only_critical_addons_enabled = false
        os_disk_size_gb              = 32
      }
    }
  }
}

variable "get_kubeconfig_to_local" {
  description = "Whether to merge kubeconfig to your local kubeconfig"
  type        = bool
  default     = false
}
