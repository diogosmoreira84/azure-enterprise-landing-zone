# Guardrails assigned at management group level, so every subscription
# placed below inherits them. Built-in definitions are looked up by display
# name to avoid hard-coding GUIDs.

data "azurerm_policy_definition_built_in" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition_built_in" "require_rg_tag" {
  display_name = "Require a tag on resource groups"
}

data "azurerm_policy_definition_built_in" "no_public_ip_on_nic" {
  display_name = "Network interfaces should not have public IPs"
}

# Data residency: resources can only be created in approved regions.
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations"
  management_group_id  = var.root_management_group_id
  policy_definition_id = data.azurerm_policy_definition_built_in.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# Ownership and cost allocation: every resource group must carry the standard tags.
resource "azurerm_management_group_policy_assignment" "require_rg_tags" {
  for_each = toset(var.required_tags)

  name                 = substr("require-rg-tag-${lower(each.value)}", 0, 24)
  display_name         = "Require tag '${each.value}' on resource groups"
  management_group_id  = var.root_management_group_id
  policy_definition_id = data.azurerm_policy_definition_built_in.require_rg_tag.id

  parameters = jsonencode({
    tagName = { value = each.value }
  })
}

# Corp landing zones are internal only: no public IPs on network interfaces.
resource "azurerm_management_group_policy_assignment" "corp_no_public_ip" {
  name                 = "corp-no-public-ip"
  display_name         = "Network interfaces should not have public IPs"
  management_group_id  = var.corp_management_group_id
  policy_definition_id = data.azurerm_policy_definition_built_in.no_public_ip_on_nic.id
}
