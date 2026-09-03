output "vm_ips" {
  value = {
    for key, value in local.structured_vm_config : key => {
      public_ip  = azurerm_linux_virtual_machine.vm[key].public_ip_address
      private_ip = azurerm_linux_virtual_machine.vm[key].private_ip_address
      vm_admin   = var.vm_config[value.vmName].admin_username
      fqdn       = azurerm_public_ip.public_ip[key].fqdn
    }
  }
}
