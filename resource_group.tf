# Resource Groups

resource "azurerm_resource_group" "rg_network_development" {
  name     = "${var.prefix}-network-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "rg_aks" {
  name     = "${var.prefix}-aks"
  location = "${var.location}"
}

resource "azurerm_resource_group" "rg_velero_development" {
  name     = "${var.prefix}-velero-development"
  location = "${var.location}"
}
