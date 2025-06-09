variable "group_name_prefix" {
  description = "Provide a prefer group name"
  type        = string
  default     = "simple-vm"
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
  default     = ""
}

variable "rg_location" {
  description = "Resource group location"
  type        = string
  default     = "eastasia"
}

variable "vritual_network_name" {
  type        = string
  description = "Virtual Network Name"
}

variable "vm_config" {
  description = <<EOF
    The configuration for the Azure Virtual Machines (VMs).
    
    (vm_names) : A map of VM names to their configurations, including:
      - subnetName         : The name of the subnet where the VM will be deployed.
      - app_sec_group_list : A list of application security group names to associate with the VM.
  EOF

  type = map(object({
    subnetName         = string
    app_sec_group_list = optional(list(string), [""])
  }))

  default = {
    "vm_names" = {
      subnetName = ""
      app_sec_group_list = [
        "webserver"
      ]
    }
  }
}

variable "subnet_config" {
  description = <<EOF
    The configuration for the Azure Subnets.
    
    (subnet_ip_ranges) : A list of IP ranges for the subnet.
    (security_rule_config) : A map of security rule configurations, where each key is a rule name and the value is an object containing:
      - priority                                    : The priority of the security rule.
      - inbound_or_outbound                         : Whether the rule is inbound or outbound. Default is true.
      - allow_access                                : Whether to allow access. Default is true.
      - protocol                                    : The protocol for the rule. Optional, default is null.
      - source_port_range                           : The source port range. Optional, default is null.
      - destination_port_range                      : The destination port range. Optional, default is null.
      - source_address_prefix                       : The source address prefix. Optional, default is null.
      - destination_address_prefix                  : The destination address prefix. Optional, default is null.
      - source_port_ranges                          : A list of source port ranges. Default is an empty list.
      - destination_port_ranges                     : A list of destination port ranges. Default is an empty list.
      - source_address_prefixes                     : A list of source address prefixes. Default is an empty list.
      - destination_address_prefixes                : A list of destination address prefixes. Default is an empty list.
      - source_application_security_group_list      : A list of source application security groups. Default is an empty list.
      - destination_application_security_group_list : A list of destination application security groups. Default is an empty list.
  EOF

  type = map(object({
    subnet_ip_ranges = list(string)

    security_rule_config = map(object({
      priority                                    = number
      inbound_or_outbound                         = optional(bool, true)
      allow_access                                = optional(bool, true)
      protocol                                    = optional(string, null)
      source_port_range                           = optional(string, null)
      destination_port_range                      = optional(string, null)
      source_address_prefix                       = optional(string, null)
      destination_address_prefix                  = optional(string, null)
      source_port_ranges                          = optional(list(string), [])
      destination_port_ranges                     = optional(list(string), [])
      source_address_prefixes                     = optional(list(string), [])
      destination_address_prefixes                = optional(list(string), [])
      source_application_security_group_list      = optional(list(string), [])
      destination_application_security_group_list = optional(list(string), [])
    }))
  }))

  default = {
    "subnet-1" = {
      subnet_ip_ranges = []

      security_rule_config = {
        "nsg_name" = {
          priority                                    = 100
          inbound_or_outbound                         = true
          allow_access                                = true
          protocol                                    = null
          source_port_range                           = null
          destination_port_range                      = null
          source_address_prefix                       = null
          destination_address_prefix                  = null
          source_port_ranges                          = []
          destination_port_ranges                     = []
          source_address_prefixes                     = []
          destination_address_prefixes                = []
          source_application_security_group_list      = []
          destination_application_security_group_list = []
        }
      }
    }
  }
}
