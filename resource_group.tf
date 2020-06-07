# Resource Groups

resource "azurerm_resource_group" "rg_network_development" {
  name     = "${var.prefix}-network-development"
  location = "${var.location}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "azurerm_resource_group" "rg_aks" {
  name     = "${var.prefix}-aks"
  location = "${var.location}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "azurerm_resource_group" "rg_vault" {
  name     = "${var.prefix}-vault"
  location = "${var.location}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "azurerm_resource_group" "rg_velero" {
  name     = "${var.prefix}-velero"
  location = "${var.location}"

  tags = {
    Environment = "${var.environment}"
  }
}
