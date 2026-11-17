output "management_group_ids" {
  description = "IDs of the management groups, keyed by role."
  value       = var.create_management_groups ? module.management_groups[0].ids : {}
}

output "log_analytics_workspace_id" {
  description = "Central Log Analytics workspace."
  value       = module.logging.workspace_id
}

output "hub_vnet_id" {
  description = "Hub virtual network."
  value       = module.hub.vnet_id
}

output "spoke_vnet_ids" {
  description = "Spoke virtual networks, keyed by workload name."
  value       = { for name, spoke in module.spokes : name => spoke.vnet_id }
}

output "firewall_private_ip" {
  description = "Private IP of Azure Firewall, when enabled."
  value       = module.hub.firewall_private_ip
}
