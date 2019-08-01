terraform {
  backend "azurerm" {
    storage_account_name  = "terraform-k8s"
    container_name        = "k8s-tfstate"
    key                   = "aks-development.terraform.tfstate"
  }
}

// Resource Groups

resource "azurerm_resource_group" "rg_network_development" {
  name     = "${var.prefix}-network-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "rg_aks_development" {
  name     = "${var.prefix}-aks-development"
  location = "${var.location}"
}

// Virtual Networks

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

// Log Analytics

resource "azurerm_log_analytics_workspace" "workspace_aks_development" {
  name                = "${var.prefix}-workspace-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "solution_aks_development" {
  solution_name         = "${var.prefix}-solution-aks-development"
  location              = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name   = "${azurerm_resource_group.rg_aks_development.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace_aks_development.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace_aks_development.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

// ACR

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}-acr-aks-development"
  resource_group_name      = "${azurerm_resource_group.rg_aks_development.name}"
  location                 = "${azurerm_resource_group.rg_aks_development.location}"
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["Canada Central", "Canada East"]

  tags = {
    Environment = "Development"
  }
}

// AKS

resource "azurerm_kubernetes_cluster" "aks_development" {
  name                = "${var.prefix}-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  dns_prefix          = "${var.prefix}-aks-development"

  load_balancer_sku   = "basic"

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
    enabling_auto_scaling = true
    min_count             = 2
    max_count             = 50
  }

  service_principal {
    client_id     = "${var.kubernetes_client_id}"
    client_secret = "${var.kubernetes_client_secret}"
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
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id = "${var.kubernetes_client_id}"
      server_app_id     = "${var.kubernetes_client_id}"
      server_app_secret = "${var.kubernetes_client_secret}"
    }
  }

  tags = {
    Environment = "Development"
  }
}
