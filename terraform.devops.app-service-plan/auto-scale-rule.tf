
resource "azurerm_monitor_autoscale_setting" "auto_scale" {
  name                = "mas${var.info.domain}${var.info.subdomain}${substr(var.info.environment, 0, 1)}${var.info.sequence}"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_app_service_plan.app_service_plan.id
  
 
   
  profile {
    name = var.profile_name

   capacity {
      default = var.default_capacity
      minimum = var.minimum_capacity
      maximum = var.maximum_capacity
    }
    
    
    # Rule 1 CPU Increase
    
     dynamic rule {
      for_each = var.rules
      content {
        metric_trigger {
          metric_name        = rule.value.metric_trigger.metric_name
          metric_resource_id = azurerm_app_service_plan.app_service_plan.id
          time_grain         = rule.value.metric_trigger.time_grain 
          statistic          = rule.value.metric_trigger.statistic 
          time_window        = rule.value.metric_trigger.time_window 
          time_aggregation   = rule.value.metric_trigger.time_aggregation 
          operator           = rule.value.metric_trigger.operator 
          threshold          = rule.value.metric_trigger.threshold 
        }
        scale_action {
          direction = rule.value.scale_action.direction
          type      = rule.value.scale_action.type
          value     = rule.value.scale_action.value
          cooldown  = rule.value.scale_action.cooldown
        }
      }
    }
  }
  notification {
      email {
      send_to_subscription_administrator    = var.admin_email_notification
      send_to_subscription_co_administrator = var.coadmin_email_notification
      }
    }
  
  depends_on = [azurerm_app_service_plan.app_service_plan]
}
