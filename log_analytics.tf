# Log Analytics

resource "azurerm_log_analytics_workspace" "workspace_aks" {
  name                = "${var.prefix}-workspace-aks"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "solution_aks" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg_aks.location
  resource_group_name   = azurerm_resource_group.rg_aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace_aks.id
  workspace_name        = azurerm_log_analytics_workspace.workspace_aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
