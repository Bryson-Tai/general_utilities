resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-network-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.env}-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.network.address_space

  subnet {
    name             = "${var.env}-subnet"
    address_prefixes = var.network.subnet.address_prefixes
  }

  tags = var.tags
}
