output "vnet_id" {
  description = "ID of the spoke virtual network."
  value       = azurerm_virtual_network.spoke.id
}

output "subnet_ids" {
  description = "Subnet IDs, keyed by subnet name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}
