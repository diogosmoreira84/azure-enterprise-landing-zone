variable "root_name" {
  description = "Display name of the organisation's top-level management group."
  type        = string
}

variable "prefix" {
  description = "Prefix used in management group IDs."
  type        = string
}

variable "subscription_id" {
  description = "Subscription GUID (without the /subscriptions/ prefix)."
  type        = string
}

variable "subscription_management_group" {
  description = "Key of the management group that receives the subscription, or null."
  type        = string
  default     = null

  validation {
    condition = (
      var.subscription_management_group == null ||
      contains(["platform", "landingzones", "corp", "online", "sandbox", "decommissioned"], coalesce(var.subscription_management_group, "none"))
    )
    error_message = "Must be one of: platform, landingzones, corp, online, sandbox, decommissioned."
  }
}
