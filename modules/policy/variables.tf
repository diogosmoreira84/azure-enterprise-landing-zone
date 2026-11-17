variable "root_management_group_id" {
  description = "Management group where organisation-wide guardrails are assigned."
  type        = string
}

variable "corp_management_group_id" {
  description = "Management group for internal (corp) landing zones."
  type        = string
}

variable "allowed_locations" {
  description = "Regions where resources may be created."
  type        = list(string)
}

variable "required_tags" {
  description = "Tag keys that every resource group must have."
  type        = list(string)
}
