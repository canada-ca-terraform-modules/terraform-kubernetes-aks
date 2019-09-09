variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "version" {
  description = "Kubernetes version"
}

variable "environment" {
  description = "Environment name to be used when tagging resources."
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "georeplication_location" {
  description = "The Azure Region to replicate georeplicated resources."
}

variable "admin_username" {
  description = "Admin username for cluster nodes."
  default = "azureuser"
}

variable "public_ssh_key_path" {
  description = "The Path at which your Public SSH Key is located. Defaults to ~/.ssh/k8s"
  default     = "~/.ssh/k8s.pub"
}

variable "node_count" {
  type = number
  description = "Number of Kubernetes worker nodes."
  default = 3
}

variable "node_size" {
  description = "VM Size for each Kubernetes worker node."
  default = "Standard_D8s_v3"
}

variable "node_disk_size" {
  type = number
  description = "Size of disk for the Kubernetes nodes (in GB)"
  default = 200
}

variable "node_pod_count" {
  type = number
  description = "Number of pods per Kubernetes node."
  default = 60
}

variable "network_plugin" {
  description = "Kubernetes networking plugin"
  default = "azure"
}

variable "network_policy" {
  description = "Kubernetes policy plugin"
  default = "azure"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  default = "172.17.0.1/16"
}

variable "dns_service_ip" {
  description = "DNS Service IP"
  default = "10.0.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  default = "10.0.0.0/16"
}

variable "vnet_cidr" {
  description = "Virtual Network CIDR"
  default = "172.15.0.0/16"
}

variable "subnet_cidr" {
  description = "Container Subnet CIDR"
  default = "172.15.4.0/22"
}

variable "load_balancer_sku" {
  description = "Load Balancer SKU"
  default = "basic"
}

variable "subscription_id" {
  description = "The Subscription ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "tenant_id" {
  description = "The Tenant ID for the Service Principal to use for this Managed Kubernetes Cluster"
}
