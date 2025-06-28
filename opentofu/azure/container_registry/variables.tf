variable "acr_configs" {
  description = <<EOF
    The configuration for the Azure Container Registry (ACR)

    location        : The Azure region where the ACR will be created.
    sku             : The SKU for the ACR, default is "Basic".
    admin_enabled   : Whether to enable the admin user, default is false.
    tags            : A map of tags to apply to the ACR.
  EOF

  type = map(object({
    location        = string
    sku             = optional(string, "Basic")
    admin_enabled   = optional(bool, false)
    tags            = map(string)
  }))

  default = {
    example = {
      location        = "West Europe"
      sku             = "Basic"
      admin_enabled   = false
      tags = {
        Environment = "Dev"
      }
    }
  }
}
