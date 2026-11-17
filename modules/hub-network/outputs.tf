output "vnet_id" {
  description = "ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "resource_group_name" {
  description = "Resource group of the hub."
  value       = azurerm_resource_group.this.name
}

output "firewall_private_ip" {
  description = "Private IP of Azure Firewall, or null when it is disabled."
  value       = var.enable_firewall ? azurerm_firewall.this[0].ip_configuration[0].private_ip_address : null
}

output "private_dns_zone_names" {
  description = "Names of the private DNS zones, keyed by zone name."
  value       = { for name, zone in azurerm_private_dns_zone.this : name => zone.name }
}
