# Storage Accounts

resource "azurerm_storage_account" "sa_velero_development" {
  name                = "${var.prefix}velero${random_string.velero_storage_account.result}"
  location            = "${azurerm_resource_group.rg_velero_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_velero_development.name}"
  account_tier = "Standard"
  account_kind = "BlobStorage"
  account_replication_type = "GRS"
  # enable_blob_encryption = "True"
  # enable_file_encryption = "True"
  access_tier = "Hot"
}

resource "azurerm_storage_container" "sc_velero_development" {
  name                  = "velero"
  resource_group_name = "${azurerm_resource_group.rg_velero_development.name}"
  storage_account_name  = "${azurerm_storage_account.sa_velero_development.name}"
  container_access_type = "private"
}
