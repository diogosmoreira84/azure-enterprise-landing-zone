resource "azurerm_resource_group" "this" {
  name     = "rg-connectivity-${var.name_suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.name_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.address_space]
  tags                = var.tags
}

# Subnets reserved for Azure-managed network services. Azure requires these
# exact names. The ranges are carved out of the hub address space.
locals {
  reserved_subnets = {
    AzureFirewallSubnet = cidrsubnet(var.address_space, 10, 0) # /26
    GatewaySubnet       = cidrsubnet(var.address_space, 11, 2) # /27
    AzureBastionSubnet  = cidrsubnet(var.address_space, 10, 2) # /26
  }
}

resource "azurerm_subnet" "reserved" {
  #checkov:skip=CKV2_AZURE_31:Firewall and Gateway subnets do not support NSGs; Bastion needs a dedicated rule set, added together with Bastion.
  for_each = local.reserved_subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

# Subnet for shared services (DNS, jump hosts, build agents), protected by an NSG.
resource "azurerm_subnet" "shared" {
  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 1)] # /24
}

resource "azurerm_network_security_group" "shared" {
  name                = "nsg-hub-shared-${var.name_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "shared" {
  subnet_id                 = azurerm_subnet.shared.id
  network_security_group_id = azurerm_network_security_group.shared.id
}

# Optional Azure Firewall: central egress filtering and inspection for all spokes.

resource "azurerm_public_ip" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                = "pip-afw-${var.name_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  count = var.enable_firewall ? 1 : 0

  name                = "afw-hub-${var.name_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.reserved["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                       = "afw-to-law"
  target_resource_id         = azurerm_firewall.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

# Private DNS zones for Private Endpoints. They live in the hub so every spoke
# resolves private service names the same way.

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.private_dns_zones)

  name                = each.value
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-hub"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = var.tags
}
