locals {
  domain    = title(var.info.domain)
  subdomain = title(var.info.subdomain)

  subproject = "${local.domain}${local.subdomain}"

  tags = merge(
    {
      for key, value in var.tags: key => title(value)
    }, 
    {
      subproject  = local.subproject
      environment = title(var.info.environment)
    }
  )

}

module naming {
  source  = "github.com/Azure/terraform-azurerm-naming?ref=64b94898f941fa1e42c6d82e4954f36e63418af5"
  // version = "0.1.0"
  suffix  = [ "${title(var.info.domain)}${title(var.info.subdomain)}" ]
}

data azurerm_subnet "subnet" {
  count                = var.vnet_integration_enabled ? 1 : 0
  resource_group_name  = var.subnet.virtual_network_resource_group_name
  virtual_network_name = var.subnet.virtual_network_name
  name                 = var.subnet.virtual_network_subnet_name
}

data "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_resource_group_name
}

data "azurerm_container_registry" "registry" {
  name                = var.registry_name 
  resource_group_name = var.registry_resource_group 
}

module private_endpoint {
  count = contains(var.private_endpoint_resources_enabled, "sites") ? 1 : 0

  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.private-endpoint?ref=v0.0.6"

  info = var.info
  tags = local.tags

  resource_group_name = var.resource_group_name
  location            = var.location

  resource_id       = azurerm_app_service.app_service.id
  subresource_names = ["sites"]

  private_endpoint_subnet = var.private_endpoint_subnet
}

resource "azurerm_app_service" "app_service" {
  name                = replace(
    format("%s%s%03d",
      lower(substr(
        module.naming.app_service.name, 0, 
        module.naming.app_service.max_length - 4
      )),
      lower(substr(title(var.info.environment), 0, 1)),
      title(var.info.sequence)
    ), "-", ""
  )
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = data.azurerm_app_service_plan.asp.id  // change it if we need to fetch 
  client_cert_enabled = false // Ask if we need it
  https_only = true
  
  identity { 
    type = "SystemAssigned" 
  }

  site_config {
    // dotnet_framework_version = var.dotnet_framework_version
    min_tls_version          = "1.2"
    ftps_state               = "FtpsOnly"
    http2_enabled            = true
    linux_fx_version         = "DOCKER|${data.azurerm_container_registry.registry.login_server}/${var.image_repository}:${var.image_tag}"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = "${data.azurerm_container_registry.registry.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = "${data.azurerm_container_registry.registry.admin_username}"
}

  // connection_string {
  //   name  = "Database"
  //   type  = "SQLServer"
  //   value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  // }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count          = var.vnet_integration_enabled ? 1 : 0
  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = data.azurerm_subnet.subnet[count.index].id
  
}


resource "azurerm_app_service_certificate" "certificate" {
  count               = var.enable_certificate ? 1:0
  name                = var.app_service_cert_name
  resource_group_name = var.resource_group_name
  location            = var.location
  pfx_blob            = filebase64("${var.cert_file}")
  password            = var.cert_password
}

resource "azurerm_app_service_custom_hostname_binding" "custom_hostname" {
  count               = var.enable_certificate ? 1:0
  hostname            = "${azurerm_app_service.app_service.name}.${var.custom_domain}"
  app_service_name    = azurerm_app_service.app_service.name
  resource_group_name = var.resource_group_name
  ssl_state           = "SniEnabled"
  thumbprint          = azurerm_app_service_certificate.certificate[0].thumbprint
  depends_on = [azurerm_app_service_certificate.certificate[0]]
  }