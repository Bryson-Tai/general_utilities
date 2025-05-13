# Generate Public & Private Key Pair for SSH
resource "tls_private_key" "vm_ssh_keys" {
  for_each = local.structured_vm_config

  algorithm = "RSA"
}

# Save Private Key to local for SSH
resource "null_resource" "save_private_key" {
  for_each = local.structured_vm_config

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c", ]

    command = templatefile("${path.module}/bash/download_private_key.sh", {
      project_postfix = each.key
      private_key     = tls_private_key.vm_ssh_keys[each.key].private_key_openssh
    })
  }

  triggers = {
    ssh_key_change = tls_private_key.vm_ssh_keys[each.key].private_key_openssh
  }
}