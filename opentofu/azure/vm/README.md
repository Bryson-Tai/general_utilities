# Project_B

<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_security_group.asg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) | resource |
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vm_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.asg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_network_security_group.network_sec_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.custom_nsg_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.disable_subnets_comm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.enable_ping](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.enable_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.sec_group_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [null_resource.configure_vm](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.save_private_key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.vm_ssh_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [http_http.ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_name_prefix"></a> [group\_name\_prefix](#input\_group\_name\_prefix) | Provide a prefer group name | `string` | `"project_c"` | no |
| <a name="input_rg_location"></a> [rg\_location](#input\_rg\_location) | Resource group location | `string` | `"eastasia"` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group name | `string` | `""` | no |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | n/a | <pre>map(object({<br>    subnet_ip_ranges = list(string)<br><br>    security_rule_config = map(object({<br>      priority                                    = number<br>      inbound_or_outbound                         = optional(bool, true)<br>      allow_access                                = optional(bool, true)<br>      protocol                                    = optional(string, null)<br>      source_port_range                           = optional(string, null)<br>      destination_port_range                      = optional(string, null)<br>      source_address_prefix                       = optional(string, null)<br>      destination_address_prefix                  = optional(string, null)<br>      source_port_ranges                          = optional(list(string), [])<br>      destination_port_ranges                     = optional(list(string), [])<br>      source_address_prefixes                     = optional(list(string), [])<br>      destination_address_prefixes                = optional(list(string), [])<br>      source_application_security_group_list      = optional(list(string), [])<br>      destination_application_security_group_list = optional(list(string), [])<br>    }))<br>  }))</pre> | <pre>{<br>  "subnet-1": {<br>    "security_rule_config": {<br>      "nsg_name": {<br>        "allow_access": true,<br>        "destination_address_prefix": null,<br>        "destination_address_prefixes": [],<br>        "destination_application_security_group_list": [],<br>        "destination_port_range": null,<br>        "destination_port_ranges": [],<br>        "inbound_or_outbound": true,<br>        "priority": 100,<br>        "protocol": null,<br>        "source_address_prefix": null,<br>        "source_address_prefixes": [],<br>        "source_application_security_group_list": [],<br>        "source_port_range": null,<br>        "source_port_ranges": []<br>      }<br>    },<br>    "subnet_ip_ranges": []<br>  }<br>}</pre> | no |
| <a name="input_vm_config"></a> [vm\_config](#input\_vm\_config) | n/a | <pre>map(object({<br>    subnetName         = string<br>    app_sec_group_list = optional(list(string), [""])<br>  }))</pre> | <pre>{<br>  "vm_names": {<br>    "app_sec_group_list": [<br>      "webserver"<br>    ],<br>    "subnetName": ""<br>  }<br>}</pre> | no |
| <a name="input_vritual_network_name"></a> [vritual\_network\_name](#input\_vritual\_network\_name) | Virtual Network Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ips"></a> [vm\_ips](#output\_vm\_ips) | n/a |
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
