# Azure App Service  
Terraform module that provisions an azure app service. When you choose sku to "Premium", you have option to create private endpoints,  georeplication_locations and network_rule_set ( White list the ip_rule).
You can integrate private endpoint with azure function itself,  keyvault and application insight. It is integrated keyvault module. 

## Usage
You can include the module by using the following code:

```

# Resource Group Module
module "rg" {
  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.resource-group?ref=v0.0.5"

  info = var.info
  tags = var.tags

  location = var.location
}

# Azure Function Module
module "app-service" {
 
  source = "git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.app-service?ref=v0.0.1"

  info = var.info
  tags = var.tags
  
  # Resource Group
  resource_group_name  = module.rg.name
  resource_group_id    = module.rg.id
  location             = var.location
 
  private_endpoint_subnet              = var.private_endpoint_subnet
  ip_whitelist                         = var.ip_whitelist
  app_service_plan_name                = var.app_service_plan_name
  app_service_plan_resource_group_name = var.app_service_plan_resource_group_name
 
  
  registry_name            = var.registry_name
  registry_resource_group  = var.registry_resource_group
  image_repository         = var.image_repository
  image_tag                = var.image_tag

  secrets           = local.secrets
  app_settings      = var.app_settings
  subnet            = var.subnet
  continuous_export = var.continuous_export
  

}
```

## Inputs

The following are the supported inputs for the module.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| info | Info object used to construct naming convention for all resources. | `object` | n/a | yes |
| tags | Tags object used to tag resources. | `object` | n/a | yes |
| resource_group | Name of the resource group where Azure Event Grid Subscription will be deployed. | `string` | n/a | yes |
| location | Location of Azure Event Grid Subscription. | `string` | n/a | yes |
| resource_group_id | The ID of the Resource Group | `string` | n/a | yes |
| app_service_plan_resource_group_name | Name of the resource group for app service plan | `string` | n/a | yes |
| app_service_plan_name | Name of the app service plan for function | `string` | n/a | yes |
| os_type | A string indicating the Operating System type for this function app | `string` | n/a | no |
| ip_whitelist | White list of ip rules | `string` | N/A | no |
| registry_name | Name of registry for docker image of fucntion | `string` | N/A | yes |
| registry_resource_group | Name of resource group of registry for docker image of fucntion | `string` | N/A | yes |
| image_repository | Name of repository for docker image of fucntion | `string` | N/A | yes |
| image_tag | Tag  of docker image of fucntion | `string` | N/A | yes |
| app_service_environment_name | Name of app service environment | `string` | "" | yes |
| vnet_integration_enabled | it is enabling to vnet integration for keyvault | `bool` | false | no |
| private_endpoint_subnet |Object that contains information to lookup the subnet to use for the privat endpoint. When private_endpoint_enabled is set to true this variable is required, otherwise it is optional  | `list of object` | [] | no |
