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

variable "acr_configs" {
  description = <<EOF
    The configuration for the Azure Container Registry (ACR)

    location        : The Azure region where the ACR will be created.
    sku             : The SKU for the ACR, default is "Basic".
    admin_enabled   : Whether to enable the admin user, default is false.
    tags            : A map of tags to apply to the ACR.
  EOF

  type = map(object({
    sku           = optional(string, "Basic")
    admin_enabled = optional(bool, false)
  }))

  default = {
    example = {
      sku           = "Basic"
      admin_enabled = false
    }
  }
}
