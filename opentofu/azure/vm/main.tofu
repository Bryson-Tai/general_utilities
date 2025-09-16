# Public IP - For SSH use
resource "azurerm_public_ip" "public_ip" {
  for_each = local.structured_vm_config

  resource_group_name = var.rg_name
  location            = var.rg_location

  name              = "${var.group_name_prefix}-${each.value.vmName}-public-ip"
  domain_name_label = replace("${var.group_name_prefix}-${each.value.vmName}", "_", "-")

  allocation_method = "Static"
}

# Network Interface Card
resource "azurerm_network_interface" "vm_nic" {
  for_each = local.structured_vm_config

  resource_group_name = var.rg_name
  location            = var.rg_location

  name = "${var.group_name_prefix}-${each.value.vmName}-vm-nic"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnetName].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
    primary                       = true
  }
}

resource "azurerm_application_security_group" "asg" {
  for_each = local.structured_asg_config

  resource_group_name = var.rg_name
  location            = var.rg_location

  name = "${var.group_name_prefix}-${each.key}-asg"
}

resource "azurerm_network_interface_application_security_group_association" "asg_assoc" {
  for_each = local.structured_asg_config

  network_interface_id          = azurerm_network_interface.vm_nic["${each.value.subnetName}-${each.value.vmName}"].id
  application_security_group_id = azurerm_application_security_group.asg[each.key].id
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.structured_vm_config

  resource_group_name = var.rg_name
  location            = var.rg_location

  name           = replace("${var.group_name_prefix}-${each.value.vmName}-vm", "_", "-")
  size           = "Standard_A2_v2"
  admin_username = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm_ssh_keys[each.key].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 32
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "null_resource" "configure_vm" {
  for_each = local.structured_vm_config

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.public_ip[each.key].ip_address
      user        = azurerm_linux_virtual_machine.vm[each.key].admin_username
      private_key = tls_private_key.vm_ssh_keys[each.key].private_key_openssh
    }

    script = "${path.module}/bash/essential_vm_setup.sh"
  }
}
