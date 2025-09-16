# Subnets
resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_config

  resource_group_name  = var.rg_name
  virtual_network_name = var.vritual_network_name

  name             = "${var.vritual_network_name}-${each.key}-subnet"
  address_prefixes = each.value.subnet_ip_ranges
}