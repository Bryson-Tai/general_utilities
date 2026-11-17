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
  type        = string
  default     = ""
}

variable "storage_configs" {
  description = <<EOT
    The configuration for the Azure Storage Account.

    name                     : Name prefix, a random 4 characters suffix is appended to keep the account name globally unique (max 20 lowercase alphanumeric characters).
    account_tier             : Standard or Premium, default is "Standard".
    account_replication_type : LRS, GRS, ZRS, etc, default is "LRS".
    account_kind             : Storage account kind, default is "StorageV2".
    min_tls_version          : Minimum TLS version, default is "TLS1_2".
    enable_smb_oauth         : Enable for Managed Identities can access SMB Azure file shares using OAuth, default is true.
  EOT

  type = object({
    name                     = string
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    account_kind             = optional(string, "StorageV2")
    min_tls_version          = optional(string, "TLS1_2")
    enable_smb_oauth         = optional(bool, true)
  })

  default = {
    name = "defoxaistorage"
  }
}

variable "file_shares" {
  description = <<EOT
    Map of Azure file shares to create, the key is the share name.

    quota_gb : Maximum size of the share in GB, default is 100.
  EOT

  type = map(object({
    quota_gb = optional(number, 100)
  }))

  default = {
    "defox-ai-files" = {}
  }
}

# variable "smb_nsg" {
#   description = <<EOT
#     Existing Network Security Group to open SMB (port 445) on, set to null to skip.

#     name                    : NSG name.
#     priority                : Rule priority, default is 1030.
#     source_address_prefixes : Allowed source addresses, default is ["*"].
#   EOT

#   type = object({
#     name                    = string
#     priority                = optional(number, 1030)
#     source_address_prefixes = optional(list(string), ["*"])
#   })

#   default = null
# }

variable "role_assignment_map" {
  description = "Object IDs of the principals (users, groups, service principals) granted access to the storage account"
  type        = map(list(string))
  default = {
    "user1" = [
      "Storage Blob Data Owner",
      "Storage File Data SMB Share Elevated Contributor",
      "Storage File Data Privileged Contributor",
      "Contributor",
      "MIC-Subscription-Contributor",
      "Storage File Data SMB MI Admin",
    ]
  }
}
