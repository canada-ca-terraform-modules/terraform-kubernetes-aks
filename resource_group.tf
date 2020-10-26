# Resource Groups

resource "azurerm_resource_group" "rg_aks" {
  name     = "${var.prefix}-aks"
  location = var.location

  tags = {
    Environment = var.environment
  }
}
