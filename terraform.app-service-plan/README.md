# App Service Plan 
Terraform module that provisions a app-service-plan. 

## Usage
You can include the module by using the following code:

```
provider "azurerm" {
  
  features {}

}
module "rg" {
  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.resource-group?ref=v1.0.0"

  info = var.info
  tags = var.tags

  location = var.location
}

# App Service Plan Module

module "app-service-plan" {
  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.app-service-plan?ref=v0.0.6"
  


  info = var.info
  tags = var.tags
  
  # Resource Group
  resource_group_name  = module.rg.name
  location             = module.rg.location
 
  rules           = var.rules      
  kind            = var.kind
  tier            = var.tier
  size            = var.size
  capacity        = var.capacity
  reserved        = var.reserved
  profile_name    = var.profile_name

  default_capacity = var.default_capacity
  minimum_capacity = var.minimum_capacity
  maximum_capacity = var.maximum_capacity
  
  app_service_environment_enabled = var.app_service_environment_enabled
  app_service_environment         = var.app_service_environment

}
```
Sample dev.tfvars

```

info = {
  domain      = "Project"      
  subdomain   = "Aries"
  environment = "Dev"
  sequence    = "008"
}



tags = {
  environment = "Dev"
  source      = "Terraform"
}


 location              = "southcentralus"

 resource_group_name   = "rg-mustafa-test"

 kind     = "Linux"

// If it is Isolated plan use like this

//  tier     = "Isolated"
 
//  size     = "I1"
 
//  capacity = 1

//  app_service_environment_enabled = true

//  app_service_environment = {
//   resource_group_name = "rgAppServiceEnvL001"
//   name                = "azbluelower"
// }
 
 
 tier                  = "Premium"
 
 size                  = "P1v3"

 capacity              = "1"

 reserved              = true

 profile_name     = "Default Profile"

 default_capacity = "1"

 minimum_capacity = "1"
 
 maximum_capacity = "3"

 rules = [
    {
      metric_trigger = {
          metric_name        = "CpuPercentage"
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
      }
      scale_action = {
        cooldown  = "PT1M"
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
      }
    },
    {
      metric_trigger = {
          metric_name        = "CpuPercentage"
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
      }
      scale_action = {
        cooldown  = "PT1M"
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
      }
    },
     {
      metric_trigger = {
          metric_name        = "MemoryPercentage"
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
      }
      scale_action = {
        cooldown  = "PT1M"
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
      }
    },
      {
      metric_trigger = {
          metric_name        = "MemoryPercentage"
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
      }
      scale_action = {
        cooldown  = "PT1M"
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
      }
    }     
  ]
```
## Inputs

The following are the supported inputs for the module.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| info | Info object used to construct naming convention for all resources. | `object` | n/a | yes |
| tags | Tags object used to tag resources. | `object` | n/a | yes |
| resource_group | Name of the resource group where the app service plan will be deployed. | `string` | n/a | yes |
| location | Location of app service plan. | `string` | n/a | yes |
| kind | The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Defaults to Windows. Changing this forces a new resource to be created. | `string` | n/a | no |
| rules | auto scaling rules for app service plan  | `list of object` | n/a | yes |
| tier | Specifies the plan's pricing tier.  | `string` | n/a | yes |
| capacity | Specifies the plan's instance size.  | `string` | n/a | yes |
| tier | pecifies the number of workers associated with this App Service Plan..  | `string` | n/a | no |
| reserved |  Is this App Service Plan Reserved. Defaults to false  | `bool` | `true` | no |
| profile_name |  Specifies the name of the profile.  | `string` | n/a | yes |
| default_capacity | The number of instances that are available for scaling if metrics are not available for evaluation. The default is only used if the current instance count is lower than the default. Valid values are between 0 and 1000.  | `string` | n/a | yes |
| minimum_capacity |  The minimum number of instances for this resource. Valid values are between 0 and 1000  | `number` | n/a | yes |
| maximum_capacity |  The maximum number of instances for this resource. Valid values are between 0 and 1000  | `number` | n/a | yes |
