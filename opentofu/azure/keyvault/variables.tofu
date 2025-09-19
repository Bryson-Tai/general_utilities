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

variable "akv" {
  description = <<EOF
    sku_name  : SKU Name
  EOF

  type = object({
    sku_name = string
  })

  default = {
    sku_name = "standard"
  }
}
