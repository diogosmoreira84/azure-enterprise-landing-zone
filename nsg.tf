resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_virtual_network.platform_dev.location
  resource_group_name = azurerm_virtual_network.platform_dev.resource_group_name

  tags = {
    environment  = "dev"
    businessUnit = "platform"
    owner        = "platform-team"
    managedBy    = "terraform"
  }
}