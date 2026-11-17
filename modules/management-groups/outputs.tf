output "root_id" {
  description = "ID of the top-level management group."
  value       = azurerm_management_group.root.id
}

output "ids" {
  description = "IDs of the child management groups, keyed by role."
  value       = local.ids
}
