variable "name" {
  description = "Budget name."
  type        = string
}

variable "subscription_id" {
  description = "Full subscription resource ID (/subscriptions/<guid>)."
  type        = string
}

variable "amount" {
  description = "Monthly budget amount."
  type        = number

  validation {
    condition     = var.amount > 0
    error_message = "The budget must be greater than zero."
  }
}

variable "start_date" {
  description = "Start of the budget period (first day of a month, RFC3339)."
  type        = string
}

variable "thresholds" {
  description = "Percentages of actual spend that trigger an alert."
  type        = list(number)
}

variable "contact_emails" {
  description = "Recipients of budget alerts."
  type        = list(string)

  validation {
    condition     = length(var.contact_emails) > 0
    error_message = "At least one contact email is required."
  }
}
