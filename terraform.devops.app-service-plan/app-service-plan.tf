
locals {
  merged_tags = merge(var.tags, {
    domain = var.info.domain
    subdomain = var.info.subdomain
  })
}

data "azurerm_app_service_environment" "ase" {
  count               = var.app_service_environment_enabled ? 1 : 0
  resource_group_name = var.app_service_environment.resource_group_name
  name                = var.app_service_environment.name
}


resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "asp${var.info.domain}${var.info.subdomain}${substr(var.info.environment, 0, 1)}${var.info.sequence}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.kind
  reserved            = var.kind == "Linux" ? true : var.reserved

  app_service_environment_id = var.app_service_environment_enabled? data.azurerm_app_service_environment.ase[0].id : null
  
  tags = local.merged_tags

  sku {
    tier     = var.tier
    size     = var.size
    capacity = var.capacity
  }

   timeouts {
    create = "90m"
    update = "90m"
    delete = "2h"
  }
}
resource null_resource azure_login {
  provisioner local-exec {
    interpreter = ["/bin/bash", "-c"]

    command = <<EOF
      az login --service-principal \
        --username $ARM_CLIENT_ID \
        --password $ARM_CLIENT_SECRET \
        --tenant $ARM_TENANT_ID
      az account set --subscription $ARM_SUBSCRIPTION_ID
    EOF
  }

  triggers = {
    always = uuid()
  }
}

resource null_resource upload_certificate {
  count = var.upload_certificate ? 1:0
  provisioner local-exec {
    interpreter = ["/bin/bash", "-c"]

    command = <<EOF
      az webapp config ssl upload \
        --certificate-file "${var.cert_file}" \
        --certificate-password "${var.cert_password}" \
        --name  "${var.certificate_name}" \
        --resource-group "${var.resource_group_name}"
      EOF  
  }

  triggers = {
    always = uuid()
    order  = null_resource.azure_login.id
  }
}