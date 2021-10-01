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

variable resource_group_name {
  type = string
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


variable front_end_scale_factor  {
    type = number
    default = 10
}
variable internal_load_balancing_mode {
    type = string
    default = "Web, Publishing"
}
variable allowed_user_ip_cidrs {
    type = list
    default = []
}

variable pricing_tier {
    type = string
    default = "I1"
}

variable cluster_setting {
    type = object (
      {
        name  = string
        value = string
      }
    )
    default = {
        name  = "DisableTls1.0"
        value = "1"
    }
  }

  variable asev3_enabled {
    type = bool
    default = true
}