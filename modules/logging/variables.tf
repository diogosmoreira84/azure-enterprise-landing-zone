variable "name_suffix" {
  description = "Suffix used in resource names, e.g. contoso-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "retention_days" {
  description = "Log retention in days."
  type        = number
}

variable "subscription_id" {
  description = "Full subscription resource ID (/subscriptions/<guid>)."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}
