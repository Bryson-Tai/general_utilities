output "aks" {
  value = {
    for key, value in var.aks_configs : aks => {
      id           = azurerm_kubernetes_cluster.aks[key].load_balancer_profile.id
      outbound_ips = azurerm_kubernetes_cluster.aks[key].load_balancer_profile.effective_outbound_ips
    }
  }

}
