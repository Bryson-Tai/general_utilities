variable "aks_configs" {
  description = "The configuration for the AKS cluster"
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
