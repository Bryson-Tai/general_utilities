output "acr" {
  description = "The name of the Azure Container Registry."
  value = {
    for key, acr in var.acr_configs : key => {
      name = azurerm_container_registry.acr[key].login_server
    }
  }
}
