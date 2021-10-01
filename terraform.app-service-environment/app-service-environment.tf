
provider azurerm {
  features {}
}

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


data "azurerm_subnet" "outbound" {
  name                 = "isolated04_outbound"
  virtual_network_name = "vnetOLBPd01"
  resource_group_name  = "spokeVnetRg"
}

resource "azurerm_app_service_environment" "ase" {
  count = var.asev3_enabled ? 0:1
  name  =  replace(
    format("%s%s%03d",
      lower(substr(
      "ase${title(var.info.domain)}${title(var.info.subdomain)}", 0, 
        37 - 4
      )),
      lower(substr(title(var.info.environment), 0, 1)),
      title(var.info.sequence)
    ), "-", ""
  )
  resource_group_name          = var.resource_group_name
  subnet_id                    = data.azurerm_subnet.outbound.id
  pricing_tier                 = var.pricing_tier
  front_end_scale_factor       = var.front_end_scale_factor
  internal_load_balancing_mode = var.internal_load_balancing_mode 
  allowed_user_ip_cidrs        = var.allowed_user_ip_cidrs

  cluster_setting {
    name  = var.cluster_setting.name
    value = var.cluster_setting.value
  }


  tags = local.tags
}

resource "azurerm_app_service_environment_v3" "aseV3" {
  count = var.asev3_enabled ? 1:0
  name                = "asev3-lower"
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.outbound.id
  internal_load_balancing_mode = var.internal_load_balancing_mode
  
  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }
  
  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }

  # cluster_setting {
  #   name  = "FrontEndSSLCipherSuiteOrder"
  #   value = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256"
  # }
  tags = local.tags

  timeouts {
    create = "180m"
    update = "120m"
    delete = "2h"
  }
}
