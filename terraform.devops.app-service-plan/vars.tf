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


variable "rules" {
  type = list(object({
    metric_trigger = object({
      metric_name = string
      time_grain = string
      statistic = string
      time_window = string
      time_aggregation = string
      operator = string
      threshold = number
    })
    scale_action = object({
      cooldown  = string
      direction = string
      type      = string
      value     = number
    })
  }))
}

variable location {}

variable resource_group_name {}

variable kind {}

variable tier {}

variable capacity {}

variable size {}

variable profile_name {}

variable default_capacity {
    type    = string
    default = "1"
}
variable minimum_capacity {
    type    = string
    default = "1"
}
variable maximum_capacity {
    type    = string
    default = "3"
}

variable reserved {
    type    = bool
    default = true 
}

variable admin_email_notification {
    type    = bool
    default = false
}

variable coadmin_email_notification {
    type    = bool
    default = false
}

variable app_service_environment {
  type = object({
    resource_group_name = string
    name                = string
  })

  description = "App service environment"
   default = {
    resource_group_name = null
    name                = null
  }
}


variable app_service_environment_enabled {
    type    = bool
    default = false
    description = "If you want to enable app service environment for isolated plan"
} 

variable upload_certificate {
  type = bool
  default = false
  description = "if you want to enable upload certificate to use it for custom domain"
}
variable cert_file {}

variable cert_password {}

variable certificate_name {}