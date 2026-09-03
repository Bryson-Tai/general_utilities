# Get your machine host IP for SSH enable
data "http" "ip" {
  url = "https://checkip.amazonaws.com"
}

# Create Network Security Group
resource "azurerm_network_security_group" "network_sec_group" {
  for_each = var.subnet_config

  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = "${var.group_name_prefix}-${each.key}-sec-group"
}

# Open Port to enable SSH, Web Server
resource "azurerm_network_security_rule" "custom_nsg_rules" {
  for_each = local.structured_subnet_sec_rule_config

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.network_sec_group[each.value.subnetName].name

  name      = each.value.security_key
  priority  = each.value.security_rule.priority
  direction = each.value.security_rule.inbound_or_outbound ? "Inbound" : "Outbound"
  access    = each.value.security_rule.allow_access ? "Allow" : "Deny"
  protocol  = each.value.security_rule.protocol

  source_port_range          = length(each.value.security_rule.source_port_ranges) > 0 ? null : each.value.security_rule.source_port_range
  destination_port_range     = length(each.value.security_rule.destination_port_ranges) > 0 ? null : each.value.security_rule.destination_port_range
  source_address_prefix      = length(each.value.security_rule.source_address_prefixes) > 0 ? null : each.value.security_rule.source_address_prefix
  destination_address_prefix = length(each.value.security_rule.destination_address_prefixes) > 0 ? null : each.value.security_rule.destination_address_prefix
  source_application_security_group_ids = length(each.value.security_rule.source_application_security_group_list) == 0 ? null : [
    for app_sec_group_name in each.value.security_rule.source_application_security_group_list : azurerm_application_security_group.asg[app_sec_group_name].id
  ]

  source_port_ranges           = length(each.value.security_rule.source_port_ranges) == 0 ? null : each.value.security_rule.source_port_ranges
  destination_port_ranges      = length(each.value.security_rule.destination_port_ranges) == 0 ? null : each.value.security_rule.destination_port_ranges
  source_address_prefixes      = length(each.value.security_rule.source_address_prefixes) == 0 ? null : each.value.security_rule.source_address_prefixes
  destination_address_prefixes = length(each.value.security_rule.destination_address_prefixes) == 0 ? null : each.value.security_rule.destination_address_prefixes
  destination_application_security_group_ids = length(each.value.security_rule.destination_application_security_group_list) == 0 ? null : [
    for app_sec_group_name in each.value.security_rule.destination_application_security_group_list : azurerm_application_security_group.asg[app_sec_group_name].id
  ]
}

# Enable SSH by Default
resource "azurerm_network_security_rule" "enable_ssh" {
  for_each = var.subnet_config

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.network_sec_group[each.key].name

  name                       = "enable_ssh"
  priority                   = 140
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = chomp(data.http.ip.response_body)
  destination_address_prefix = "*"
}

# Enable to Ping by Default
resource "azurerm_network_security_rule" "enable_ping" {
  for_each = var.subnet_config

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.network_sec_group[each.key].name

  name                       = "enable_ping"
  priority                   = 150
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Icmp"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

# Disable communication among Subnets in Virtual Network
resource "azurerm_network_security_rule" "disable_subnets_comm" {
  for_each = var.subnet_config

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.network_sec_group[each.key].name

  name                       = "disable_subnets_comm_inbound"
  priority                   = 1000
  direction                  = "Inbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
}

# Associate this network security group to subnet
#! We could associate this to Network Interface Card (NIC) too
resource "azurerm_subnet_network_security_group_association" "sec_group_assoc" {
  for_each = var.subnet_config

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.network_sec_group[each.key].id
}