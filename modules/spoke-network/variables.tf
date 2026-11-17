variable "name" {
  description = "Workload name, used in resource names."
  type        = string
}

variable "name_suffix" {
  description = "Suffix used in resource names, e.g. contoso-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Spoke address space. Must not overlap with the hub or other spokes."
  type        = string
}

variable "subnets" {
  description = "Subnets to create, as name => CIDR."
  type        = map(string)
}

variable "hub_vnet_id" {
  description = "ID of the hub virtual network."
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network."
  type        = string
}

variable "hub_resource_group" {
  description = "Resource group of the hub virtual network."
  type        = string
}

variable "route_via_firewall" {
  description = "Send all outbound traffic through the hub firewall."
  type        = bool
  default     = false
}

variable "firewall_private_ip" {
  description = "Private IP of the hub firewall. Required when route_via_firewall is true."
  type        = string
  default     = null
}

variable "private_dns_zone_names" {
  description = "Private DNS zones in the hub that this spoke should be linked to."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}
