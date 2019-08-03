variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "public_ssh_key_path" {
  description = "The Path at which your Public SSH Key is located. Defaults to ~/.ssh/k8s"
  default     = "~/.ssh/k8s.pub"
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
