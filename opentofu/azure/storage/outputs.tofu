output "storage" {
  value = {
    id                  = azurerm_storage_account.storage.id
    name                = azurerm_storage_account.storage.name
    resource_group_name = azurerm_resource_group.rg.name
    file_endpoint       = azurerm_storage_account.storage.primary_file_endpoint
    file_share_names    = keys(azurerm_storage_share.file_share)
  }
}

output "primary_access_key" {
  value     = azurerm_storage_account.storage.primary_access_key
  sensitive = true
}
