# Storage Accounts

resource "azurerm_storage_account" "sa_vault" {
  name                     = "${var.short_prefix}vault${random_string.vault_storage_account.result}"
  location                 = "${azurerm_resource_group.rg_vault.location}"
  resource_group_name      = "${azurerm_resource_group.rg_vault.name}"
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
  # enable_blob_encryption = "True"
  # enable_file_encryption = "True"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "sc_vault" {
  name                  = "vault"
  storage_account_name  = "${azurerm_storage_account.sa_vault.name}"
  container_access_type = "private"
}

resource "azurerm_storage_account" "sa_velero" {
  name                     = "${var.short_prefix}velero${random_string.velero_storage_account.result}"
  location                 = "${azurerm_resource_group.rg_velero.location}"
  resource_group_name      = "${azurerm_resource_group.rg_velero.name}"
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
  # enable_blob_encryption = "True"
  # enable_file_encryption = "True"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "sc_velero" {
  name                  = "velero"
  storage_account_name  = "${azurerm_storage_account.sa_velero.name}"
  container_access_type = "private"
}
