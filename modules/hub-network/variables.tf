variable "name_suffix" {
  description = "Suffix used in resource names, e.g. contoso-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Hub address space, e.g. 10.0.0.0/16."
  type        = string

  validation {
    condition     = can(cidrhost(var.address_space, 0))
    error_message = "Must be a valid CIDR range."
  }
}

variable "enable_firewall" {
  description = "Deploy Azure Firewall in the hub."
  type        = bool
}

variable "private_dns_zones" {
  description = "Private DNS zones to create in the hub, e.g. privatelink.blob.core.windows.net."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Workspace that receives firewall logs."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}
