resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.storage_configs.name}${length(var.resource_postfix) > 0 ? "-${var.resource_postfix}" : ""}-rg"
  location = var.location

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                = "${replace(var.storage_configs.name, "-", "")}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier                    = var.storage_configs.account_tier
  account_replication_type        = var.storage_configs.account_replication_type
  account_kind                    = var.storage_configs.account_kind
  min_tls_version                 = var.storage_configs.min_tls_version
  allow_nested_items_to_be_public = false

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_share" "file_share" {
  for_each = var.file_shares

  name               = each.key
  storage_account_id = azurerm_storage_account.storage.id
  quota              = each.value.quota_gb
}

# Allow SMB (port 445) on an existing NSG, e.g. the one created by the virtual-machine module
resource "azurerm_network_security_rule" "allow_smb_inbound" {
  count = var.smb_nsg != null ? 1 : 0

  name                        = "allow-smb-inbound"
  resource_group_name         = var.smb_nsg.resource_group_name
  network_security_group_name = var.smb_nsg.name
  priority                    = var.smb_nsg.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefixes     = var.smb_nsg.source_address_prefixes
  destination_address_prefix  = "*"
}

resource "azurerm_role_assignment" "storage_roles" {
  for_each = {
    for pair in setproduct(var.role_assignment_principal_ids, var.role_assignment_roles) :
    "${pair[0]}-${pair[1]}" => { principal_id = pair[0], role = pair[1] }
  }

  scope                = azurerm_storage_account.storage.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}
