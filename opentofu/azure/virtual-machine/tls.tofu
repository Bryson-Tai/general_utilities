# Generate Public & Private Key Pair for SSH
resource "tls_private_key" "vm_ssh_keys" {
  for_each = local.structured_vm_config

  algorithm = "RSA"
}

# Save Private Key to local for SSH
resource "terraform_data" "save_private_key" {
  for_each = local.structured_vm_config

  # Save the private key to a local file
  provisioner "local-exec" {
    when        = create
    interpreter = ["/bin/bash", "-c", ]

    command = templatefile("${path.module}/bash/vm_private_key.sh", {
      project_postfix = each.key
      private_key     = tls_private_key.vm_ssh_keys[each.key].private_key_openssh
    })

    environment = {
      CREATE_PRIVATE_KEY = "true"
    }
  }

  # Clean up the private key file when destroying the resource
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c", ]

    command = templatefile("${path.module}/bash/vm_private_key.sh", {
      project_postfix = each.key
      private_key     = "to-be-destroy"
    })

    environment = {
      DELETE_PRIVATE_KEY = "true"
    }
  }

  triggers_replace = [
    tls_private_key.vm_ssh_keys[each.key].private_key_openssh
  ]
}
