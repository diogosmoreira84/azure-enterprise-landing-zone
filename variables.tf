variable "subscription_id" {
  description = "Subscription where the platform resources are deployed."
  type        = string
}

variable "prefix" {
  description = "Short prefix used in every resource name, e.g. the company initials."
  type        = string
  default     = "contoso"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.prefix))
    error_message = "The prefix must be 2 to 8 lowercase letters or digits."
  }
}

variable "environment" {
  description = "Environment name used in names and tags."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "northeurope"
}

variable "allowed_locations" {
  description = "Regions where resources may be created. Enforced by Azure Policy."
  type        = list(string)
  default     = ["northeurope", "westeurope"]
}

variable "tags" {
  description = "Tags applied to every resource. Their keys are also required on resource groups by policy."
  type        = map(string)
  default = {
    owner        = "platform-team"
    businessUnit = "platform"
    costCenter   = "it-platform"
  }
}

# Management groups

variable "create_management_groups" {
  description = "Create the management group hierarchy and policy assignments. Requires permissions at tenant root."
  type        = bool
  default     = true
}

variable "root_management_group_name" {
  description = "Display name of the top-level management group for the organisation."
  type        = string
  default     = "Contoso"
}

variable "subscription_management_group" {
  description = "Management group key where the current subscription is placed (platform, corp, online, sandbox). Leave null to keep it where it is."
  type        = string
  default     = null
}

# Networking

variable "hub_address_space" {
  description = "Address space of the hub virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "spokes" {
  description = "Spoke virtual networks, keyed by workload name. Each subnet gets its own network security group."
  type = map(object({
    address_space = string
    subnets       = map(string)
  }))
  default = {
    app = {
      address_space = "10.10.0.0/16"
      subnets = {
        web  = "10.10.1.0/24"
        app  = "10.10.2.0/24"
        data = "10.10.3.0/24"
      }
    }
  }
}

variable "enable_firewall" {
  description = "Deploy Azure Firewall in the hub and route spoke traffic through it. Off by default because it has a significant fixed cost."
  type        = bool
  default     = false
}

variable "private_dns_zones" {
  description = "Private DNS zones for Private Endpoints, hosted in the hub and linked to every spoke."
  type        = list(string)
  default     = []
}

# Logging

variable "log_retention_days" {
  description = "Retention of the central Log Analytics workspace, in days."
  type        = number
  default     = 30
}

# Cost controls

variable "budget_amount" {
  description = "Monthly budget for the subscription, in the billing currency."
  type        = number
  default     = 5
}

variable "budget_start_date" {
  description = "First day of the budget period, in RFC3339 format. Must be the first day of a month."
  type        = string
  default     = "2026-08-01T00:00:00Z"
}

variable "budget_thresholds" {
  description = "Percentages of the budget that trigger an alert."
  type        = list(number)
  default     = [50, 80, 100]
}

variable "budget_contact_emails" {
  description = "Who receives budget alerts."
  type        = list(string)
}
