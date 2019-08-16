# Terraform for Azure Kubernetes Service

The overall flow for this module is pretty simple:

* Create Azure storage account to store Terraform state
* Create Azure AKS configuration in a modular manner
* Deploy the infrastructure incrementally

## Pre-requisites

As currently Multiple Agent Pools and Virtual Machine Scalesets are in preview you will need to run the following commands.

```sh
# Install the aks-preview extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview

# Registration
az feature register --name MultiAgentpoolPreview --namespace Microsoft.ContainerService
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
```

## Init

Ensure you have exported the ARM access key for storage account.

```sh
export ARM_ACCESS_KEY=<secret>
```

Set the backend config parameters for the AzureRM Terraform provider.

```sh
terraform init\
    -backend-config="storage_account_name=terraformkubernetes" \
    -backend-config="container_name=k8s-tfstate" \
    -backend-config="key=aks-development.terraform.tfstate"
```

## Plan

```sh
terraform plan -out plan
```

## Apply

```sh
terraform apply plan
```
