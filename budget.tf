data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "dm84_lab" {
  name            = "dm84-lab-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 5
  time_grain = "Monthly"

  time_period {
    start_date = "2026-08-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [
      "mdiogo.moreira@gmail.com"
    ]
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [
      "mdiogo.moreira@gmail.com"
    ]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [
      "mdiogo.moreira@gmail.com"
    ]
  }
}