terraform {
  backend "azurerm" {
    storage_account_name  = "terraformkubernetes"
    container_name        = "k8s-tfstate"
    key                   = "aks-development.terraform.tfstate"
  }
}

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

# Virtual Networks

resource "azurerm_virtual_network" "vnet_aks_development" {
  name                = "${var.prefix}-vnet-aks-development"
  location            = "${azurerm_resource_group.rg_network_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_network_development.name}"
  address_space       = ["172.15.0.0/16"]
}

resource "azurerm_subnet" "subnet_aks_development" {
  name                 = "containers"
  resource_group_name  = "${azurerm_resource_group.rg_network_development.name}"
  address_prefix       = "172.15.4.0/22"
  virtual_network_name = "${azurerm_virtual_network.vnet_aks_development.name}"
}

# Log Analytics

resource "azurerm_log_analytics_workspace" "workspace_aks_development" {
  name                = "${var.prefix}-workspace-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "solution_aks_development" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name   = "${azurerm_resource_group.rg_aks_development.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace_aks_development.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace_aks_development.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# ACR

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}"
  resource_group_name      = "${azurerm_resource_group.rg_aks_development.name}"
  location                 = "${azurerm_resource_group.rg_aks_development.location}"
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["Canada East"]

  tags = {
    Environment = "Development"
  }
}

# Azure AD Server

resource "azuread_application" "server" {
  name                    = "k8s_server"
  reply_urls              = ["http://k8s_server"]
  type                    = "webapp/api"
  group_membership_claims = "All"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # MicrosoftGraph API
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data":
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile":
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "server" {
  application_id = "${azuread_application.server.application_id}"
}

resource "azuread_service_principal_password" "server" {
  service_principal_id = "${azuread_service_principal.server.id}"
  value                = "${random_string.application_server_password.result}"
  end_date             = "${timeadd(timestamp(), "87600h")}" # 10 years

  # The end date will change at each run (terraform apply), causing a new password to
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = ["end_date"]
  }
}

# Passwords

resource "random_string" "application_server_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.server.id}"
  }
}

resource "random_string" "velero_password" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "velero_storage_account" {
  length  = 5
  special = false
  upper   = false
}

# Azure AD Client

resource "azuread_application" "client" {
  name       = "k8s_client"
  reply_urls = ["http://k8s_client"]
  type       = "native"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # AKS ad application server
    resource_app_id = "${azuread_application.server.application_id}"

    resource_access {
      # Server app Oauth2 permissions id
      id   = "${lookup(azuread_application.server.oauth2_permissions[0], "id")}"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "client" {
  application_id = "${azuread_application.client.application_id}"
}

resource "azuread_service_principal_password" "client" {
  service_principal_id = "${azuread_service_principal.client.id}"
  value                = "${random_string.application_client_password.result}"
  end_date             = "${timeadd(timestamp(), "87600h")}"

  lifecycle {
    ignore_changes = ["end_date"]
  }
}

resource "random_string" "application_client_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azuread_service_principal.client.id}"
  }
}

# Velero

resource "azuread_application" "velero" {
  name                    = "k8s_velero"
  reply_urls              = ["http://k8s_velero"]
  type                    = "webapp/api"
  group_membership_claims = "All"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # MicrosoftGraph API
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data":
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile":
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "velero" {
  application_id = "${azuread_application.velero.application_id}"
}

resource "azuread_service_principal_password" "velero" {
  service_principal_id = "${azuread_service_principal.velero.id}"
  value                = "${random_string.velero_password.result}"
  end_date             = "${timeadd(timestamp(), "87600h")}" # 10 years

  # The end date will change at each run (terraform apply), causing a new password to
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = ["end_date"]
  }
}

# AKS Cluster

resource "azurerm_kubernetes_cluster" "aks_development" {
  name                = "${var.prefix}-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  dns_prefix          = "${var.prefix}-aks-development"

  kubernetes_version  = "1.14.3"

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "${file(var.public_ssh_key_path)}"
    }
  }

  agent_pool_profile {
    name                  = "nodepool1"
    count                 = 2
    vm_size               = "Standard_D8s_v3"
    os_type               = "Linux"
    os_disk_size_gb       = 200
    max_pods              = 60
    vnet_subnet_id        = "${azurerm_subnet.subnet_aks_development.id}"
    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = false
    # min_count             = 2
    # max_count             = 50
  }

  service_principal {
    client_id     = "${azuread_application.client.application_id}"
    client_secret = "${azuread_service_principal_password.client.value}"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.workspace_aks_development.id}"
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip = "10.0.0.10"
    service_cidr = "10.0.0.0/16"
    load_balancer_sku   = "basic"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = "${azuread_application.client.application_id}"
      server_app_id     = "${azuread_application.server.application_id}"
      server_app_secret = "${azuread_service_principal_password.server.value}"
    }
  }

  tags = {
    Environment = "Development"
  }
}
