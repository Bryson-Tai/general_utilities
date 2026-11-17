output "aks" {
  value = {
    id   = azurerm_kubernetes_cluster.aks.id
    name = split("/", azurerm_kubernetes_cluster.aks.id)[length(split("/", azurerm_kubernetes_cluster.aks.id)) - 1]
  }
}
