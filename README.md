# Terraform for Azure Kubernetes Service

The overall flow for this module is pretty simple:

* Create Azure storage account to store Terraform state
* Create Azure AKS configuration in a modular manner
* Deploy the infrastructure incrementally

## Security Controls

The following security controls can be met through configuration of this template:

* TBD

## Dependencies

* None

## Optional (depending on options configured):

* None

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

## Workflow

1. Create terraform.tfvars based on example template provider.

Azure Active Directory Graph

* Application.ReadWrite.All (Application)
* User.Read (Delegated)

Microsoft Graph

* Applications.ReadWrite.OwnedBy (Application)
* User.Read (Delegated)

> Note: If you’re authenticating using a Service Principal (client_id) then it must have the appropriate permissions. See the following link on how to add the required permissions given above: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis#add-permissions-to-access-web-apis. Additionally please don't forget to grant admin consent and add the service principal with role `Contributor` to the desired Subscription.

2. Ensure you have exported the `ARM_ACCESS_KEY` for the Terraform backend storage account.

```sh
export ARM_ACCESS_KEY=<secret>
```

3. Initialize and set the Terraform backend configuration parameters for the AzureRM provider.

```sh
terraform init\
    -backend-config="storage_account_name=terraformkubernetes" \
    -backend-config="container_name=k8s-tfstate" \
    -backend-config="key=${prefix}-aks.terraform.tfstate"
```

> Note: You will have to specify your own storage account name for where to store the Terraform state. Also don't forget to create your container name which in this instance is k8s-tfstate.

4. Create an execution plan and save the generated plan to a file.

```sh
terraform plan -out plan
```

5. Apply the changes only for the server and client applications

```sh
terraform apply -target azuread_service_principal.server -target azuread_service_principal.client
```

> Now go on the Azure Portal and Grant admin consent manually on both applications (the `k8s_server_${prefix}`, then the `k8s_client_${prefix}`).

6. Apply the remainder of changes required to reach desired state.

```sh
terraform plan -out plan
terraform apply plan
```

8. KubeConfig

a) Admin level AKS credentials to assign further RBAC.

```sh
az aks get-credentials --resource-group ${prefix}-aks --name ${prefix}-aks --admin --overwrite-existing
```

b) User level kubeconfig context.

```sh
terraform output kube_config > kubeconfig
```

## Usage

```terraform
# terraform.tfvars

prefix = "department"
short_prefix = "dept"
environment = "aks"
kube_version = "1.15.3"
location = "Canada Central"
georeplication_region = "Canada East"
admin_username = "azureuser"
node_count = 3
node_size = "Standard_D8s_v3"
node_pod_count = 60
public_ssh_key_path = "~/.ssh/k8s.pub"
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""
```

## Variables Values

| Name                  | Type   | Required | Value                                                                                    |
| --------------------- | ------ | -------- | ---------------------------------------------------------------------------------------- |
| prefix                | string | yes      | A prefix used for all resources in this example                                          |
| short_prefix          | string | yes      | A short prefix used for all resources in this example                                    |
| kube_version          | string | yes      | Kubernetes version                                                                       |
| environment           | string | yes      | Environment name to be used when tagging resources                                       |
| location              | string | yes      | The Azure Region in which all resources in this example should be provisioned            |
| georeplication_region | string | yes      | The Azure Region to replicate georeplicated resources                                    |
| admin_username        | string | yes      | Admin username for cluster nodesT                                                        |
| public_ssh_key_path   | string | yes      | The Path at which your Public SSH Key is located. Defaults to ~/.ssh/k8s                 |
| node_count            | number | yes      | Number of Kubernetes worker nodes                                                        |
| node_size             | string | yes      | VM Size for each Kubernetes worker node                                                  |
| node_disk_size        | number | yes      | Size of disk for the Kubernetes nodes (in GB)                                            |
| node_pod_count        | number | yes      | Number of pods per Kubernetes node                                                       |
| network_plugin        | string | yes      | Kubernetes networking plugin                                                             |
| network_policy        | string | yes      | Kubernetes policy plugin                                                                 |
| docker_bridge_cidr    | string | yes      | Docker bridge CIDR                                                                       |
| dns_service_ip        | string | yes      | DNS Service IP                                                                           |
| service_cidr          | string | yes      | Service CIDR                                                                             |
| vnet_cidr             | string | yes      | Virtual Network CIDR                                                                     |
| subnet_cidr           | string | yes      | Container Subnet CIDR                                                                    |
| load_balancer_sku     | string | yes      | Load Balancer SKU                                                                        |
| subscription_id       | string | yes      | The Subscription ID for the Service Principal to use for this Managed Kubernetes Cluster |
| client_id             | string | yes      | The Client ID for the Service Principal to use for this Managed Kubernetes Cluster       |
| client_secret         | string | yes      | The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster   |
| tenant_id             | string | yes      | The Tenant ID for the Service Principal to use for this Managed Kubernetes Cluster       |

## History

| Date     | Release    | Change                                                     |
| -------- | ---------- | ---------------------------------------------------------- |
| 20190729 | 20190729.1 | Improvements to documentation and formatting               |
| 20190909 | 20190909.1 | 1st release                                                |
