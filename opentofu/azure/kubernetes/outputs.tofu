output "aks" {
  value = {
    for key, value in var.aks_configs : key => {
      id   = azurerm_kubernetes_cluster.aks.id
      name = split("/", azurerm_kubernetes_cluster.aks.id)[-1]
    }
  }
}
