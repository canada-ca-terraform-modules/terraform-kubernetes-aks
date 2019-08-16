# Resource Groups

resource "azurerm_resource_group" "rg_network_development" {
  name     = "${var.prefix}-network-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "rg_aks_development" {
  name     = "${var.prefix}-aks-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "rg_velero_development" {
  name     = "${var.prefix}-velero-development"
  location = "${var.location}"
}
