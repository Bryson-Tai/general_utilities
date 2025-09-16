locals {
  vm_config = flatten([
    for vmName, vmConfig in var.vm_config : [
      for app_sec_group_name in vmConfig.app_sec_group_list : {
        vmName             = vmName
        subnetName         = vmConfig.subnetName
        app_sec_group_name = app_sec_group_name
      }
    ]
  ])

  subnet_sec_rule_config = flatten([
    for subnetName, subnetConfig in var.subnet_config : [
      for security_key, security_rule in subnetConfig.security_rule_config : {
        subnetName    = subnetName
        security_key  = security_key
        security_rule = security_rule
      }
    ]
  ])

  structured_vm_config = {
    for i, config in local.vm_config : "${config.subnetName}-${config.vmName}" => config
  }

  structured_subnet_sec_rule_config = {
    for i, config in local.subnet_sec_rule_config : "${config.subnetName}-${config.security_key}" => config
  }

  structured_asg_config = {
    for key, value in local.structured_vm_config : value.app_sec_group_name => value if length(value.app_sec_group_name) > 0
  }
}
