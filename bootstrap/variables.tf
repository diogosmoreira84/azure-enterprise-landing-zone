variable "subscription_id" {
  description = "Subscription where the state storage account is created."
  type        = string
}

variable "prefix" {
  description = "Same prefix as the landing zone, 2 to 8 lowercase letters or digits."
  type        = string
  default     = "contoso"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Tags applied to the state resources."
  type        = map(string)
  default = {
    owner        = "platform-team"
    businessUnit = "platform"
    costCenter   = "it-platform"
    managedBy    = "terraform"
  }
}
