variable "acr_configs" {
  description = "The configuration for the AKS cluster"
  type = map(object({
    resource_prefix = optional(string)
    location        = string
    sku             = optional(string, "Basic")
    admin_enabled   = optional(bool, false)
    tags            = map(string)
  }))

  default = {
    example = {
      resource_prefix = "example"
      location        = "West Europe"
      sku             = "Basic"
      admin_enabled   = false
      tags = {
        Environment = "Dev"
      }
    }
  }
}
