variable "aks_configs" {
  description = <<EOF
    The configuration for the Azure Kubernetes Service (AKS) cluster.

    resource_prefix : Prefix for the resource name, optional.
    location        : The Azure region where the AKS cluster will be created.
    default_node_pool : Configuration for the default node pool, including:
      - name                          : Name of the node pool.
      - vm_size                       : Size of the virtual machines in the node pool.
      - node_count                    : Number of nodes in the node pool, default is 1.
      - only_critical_addons_enabled  : Whether to enable only critical addons, default is false.
    tags            : A map of tags to apply to the AKS cluster.
  EOF

  type = map(object({
    resource_prefix = string
    location        = string
    default_node_pool = object({
      name                         = string
      vm_size                      = string
      node_count                   = optional(number, 1)
      only_critical_addons_enabled = optional(bool, false)
    })
    tags = map(string)
  }))

  default = {
    example = {
      resource_prefix = "example"
      location        = "West Europe"
      default_node_pool = {
        name                         = "default"
        vm_size                      = "Standard_D2_v2"
        node_count                   = 1
        only_critical_addons_enabled = false
      }
      tags = {
        Environment = "Dev"
      }
    }
  }
}
