# Management group hierarchy based on the Azure Cloud Adoption Framework:
#
#   <Organisation>
#   ├── Platform  (shared services: management, connectivity, identity)
#   ├── Landing zones
#   │   ├── Corp    (internal workloads, no public exposure)
#   │   └── Online  (internet-facing workloads)
#   ├── Sandbox   (experiments, loose policies)
#   └── Decommissioned

resource "azurerm_management_group" "root" {
  name         = "${var.prefix}-root"
  display_name = var.root_name
}

resource "azurerm_management_group" "level1" {
  for_each = {
    platform       = "Platform"
    landingzones   = "Landing zones"
    sandbox        = "Sandbox"
    decommissioned = "Decommissioned"
  }

  name                       = "${var.prefix}-${each.key}"
  display_name               = each.value
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "landing_zones" {
  for_each = {
    corp   = "Corp"
    online = "Online"
  }

  name                       = "${var.prefix}-${each.key}"
  display_name               = each.value
  parent_management_group_id = azurerm_management_group.level1["landingzones"].id
}

locals {
  ids = merge(
    { for key, mg in azurerm_management_group.level1 : key => mg.id },
    { for key, mg in azurerm_management_group.landing_zones : key => mg.id },
  )
}

resource "azurerm_management_group_subscription_association" "this" {
  count = var.subscription_management_group == null ? 0 : 1

  management_group_id = local.ids[var.subscription_management_group]
  subscription_id     = "/subscriptions/${var.subscription_id}"
}
