resource "azurerm_resource_group" "this" {
  name     = "rg-management-${var.name_suffix}"
  location = var.location
  tags     = var.tags
}

# Central workspace for platform logs and metrics.
resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-platform-${var.name_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# Send the subscription Activity Log (who changed what, policy and security
# events) to the central workspace.
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "activity-log-to-law"
  target_resource_id         = var.subscription_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = ["Administrative", "Security", "Policy", "Alert", "ServiceHealth", "ResourceHealth"]

    content {
      category = enabled_log.value
    }
  }
}
