provider "azuread" {
  version = "=0.5.1"

  subscription_id = "${var.subscription_id}"
}

provider "azurerm" {
  version         = "=1.44.0"
  subscription_id = "${var.subscription_id}"
}
