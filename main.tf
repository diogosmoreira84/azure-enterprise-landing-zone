locals {
  name_suffix = "${var.prefix}-${var.environment}"

  tags = merge(var.tags, {
    environment = var.environment
    managedBy   = "terraform"
  })
}

data "azurerm_subscription" "current" {}

# Governance: management groups and policy

module "management_groups" {
  source = "./modules/management-groups"
  count  = var.create_management_groups ? 1 : 0

  root_name                     = var.root_management_group_name
  prefix                        = var.prefix
  subscription_id               = data.azurerm_subscription.current.subscription_id
  subscription_management_group = var.subscription_management_group
}

module "policy" {
  source = "./modules/policy"
  count  = var.create_management_groups ? 1 : 0

  root_management_group_id = module.management_groups[0].root_id
  corp_management_group_id = module.management_groups[0].ids["corp"]
  allowed_locations        = var.allowed_locations
  required_tags            = keys(var.tags)
}

# Management: central logging

module "logging" {
  source = "./modules/logging"

  name_suffix     = local.name_suffix
  location        = var.location
  retention_days  = var.log_retention_days
  subscription_id = data.azurerm_subscription.current.id
  tags            = local.tags
}

# Connectivity: hub and spokes

module "hub" {
  source = "./modules/hub-network"

  name_suffix                = local.name_suffix
  location                   = var.location
  address_space              = var.hub_address_space
  enable_firewall            = var.enable_firewall
  private_dns_zones          = var.private_dns_zones
  log_analytics_workspace_id = module.logging.workspace_id
  tags                       = local.tags
}

module "spokes" {
  source   = "./modules/spoke-network"
  for_each = var.spokes

  name                   = each.key
  name_suffix            = local.name_suffix
  location               = var.location
  address_space          = each.value.address_space
  subnets                = each.value.subnets
  hub_vnet_id            = module.hub.vnet_id
  hub_vnet_name          = module.hub.vnet_name
  hub_resource_group     = module.hub.resource_group_name
  route_via_firewall     = var.enable_firewall
  firewall_private_ip    = module.hub.firewall_private_ip
  private_dns_zone_names = keys(module.hub.private_dns_zone_names)
  tags                   = local.tags
}

# Cost controls

module "budget" {
  source = "./modules/budget"

  name            = "budget-${local.name_suffix}"
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.budget_amount
  start_date      = var.budget_start_date
  thresholds      = var.budget_thresholds
  contact_emails  = var.budget_contact_emails
}
