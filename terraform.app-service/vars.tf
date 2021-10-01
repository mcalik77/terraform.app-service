terraform {
  experiments = [module_variable_optional_attrs]
}

variable info {
  type = object({
    domain      = string
    subdomain   = string
    environment = string
    sequence    = string
  })

  description = "Info object used to construct naming convention for all resources."
}

variable tags {
  type        = map(string)
  description = "Tags object used to tag resources."
}

variable continuous_export {
  type = object({
    resource_group_name  = string
    storage_account_name = string
    container_name       = string
  })
}

variable subnet{
  type = object (
    {
      virtual_network_name                = string
      virtual_network_subnet_name         = string
      virtual_network_resource_group_name = string
    }
  )

  default = {
    virtual_network_name                = null
    virtual_network_subnet_name         = null
    virtual_network_resource_group_name = null
  }
}

variable vnet_integration_enabled {
  type        = bool
  description = "Determines if vnet integration should be enabled for the app."
  default = false
}

variable app_service_plan_name {}

variable app_service_plan_resource_group_name {}

variable location {}

variable resource_group_name {}

variable resource_group_id {}

variable registry_name {}

variable registry_resource_group {}

variable image_repository {}

variable image_tag {}

variable secrets{
  type = list(object(
    {
      key   = string
      value = string
    }
  ))
  default = []
}

variable app_settings {
  default = {}
}

variable app_service_environment_name {
  type    = string 
  default = ""
}

variable private_endpoint_resources_enabled {
  type  = list
  default = ["sites", "keyVault"]
  
  validation {
    condition = length([
      for resource in var.private_endpoint_resources_enabled : true
      if contains(["keyVault"], resource  ) || 
         contains(["sites"], resource     ) ]) == length(var.private_endpoint_resources_enabled)

    error_message = "The private_endpoint_resources_enabled list must be one of [\"keyVault\", \"sites\"]."
    
  }
}

variable private_endpoint_subnet{
  type = object (
    {
      virtual_network_name                = string
      virtual_network_subnet_name         = string
      virtual_network_resource_group_name = string
    }
  )

  default = {
    virtual_network_name                = null
    virtual_network_subnet_name         = null
    virtual_network_resource_group_name = null
  }
}

variable ip_whitelist {
  description = "List of public IP or IP ranges in CIDR Format to allow."
  default     = ["204.153.155.151/32"]
}

variable custom_domain  {
  type = string
  default = ""
}

variable enable_certificate {
  type = bool
  default = false
}

variable app_service_cert_name  {
  type = string
  default = ""
}

variable cert_file  {
  type = string
  default = ""
}

variable cert_password  {
  type = string
  default = ""
}

variable managed_identities {
  type = list(object({
    principal_name = string
    roles          = optional(list(string))
  }))
  description = "The name of manage identities(Service principal or Application name) to give key-vault access"
  default = []
}
