resource "azurerm_virtual_network" "platform_dev" {
  name                = "vnet-platform-dev"
  location            = "northeurope"
  resource_group_name = "rg-platform-dev"
  address_space       = ["10.10.0.0/16"]

  tags = {
    environment  = "dev"
    businessUnit = "platform"
    owner        = "platform-team"
    managedBy    = "terraform"
  }
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_virtual_network.platform_dev.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform_dev.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_virtual_network.platform_dev.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform_dev.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_virtual_network.platform_dev.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform_dev.name
  address_prefixes     = ["10.10.3.0/24"]
}