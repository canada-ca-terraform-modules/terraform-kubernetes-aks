# Terraform for Azure Kubernetes Service

The overall flow for this module is pretty simple:

* Create Azure storage account to store Terraform state
* Create Azure AKS configuration in a modular manner
* Deploy the infrastructure incrementally

> Note: We have also provided a GitHub actions template to be used with private repositories.

## Security Controls

We have recieved Authority to Operate and are happy to share our supporting documentation:

* Concept of Operations
* IT Security Controls (100+)
* CIS Benchmarks
* IBM Assessment

## Dependencies

* None

## Optional (depending on options configured)

* None

## Workflow

1. Ensure you have exported the `ARM_ACCESS_KEY` for the Terraform backend storage account.

```sh
export ARM_ACCESS_KEY=<secret>
```

2. Initialize and set the Terraform backend configuration parameters for the AzureRM provider.

```sh
terraform init\
    -backend-config="storage_account_name=terraform-$prefix" \
    -backend-config="container_name=k8s-tfstate" \
    -backend-config="key=$prefix-aks.terraform.tfstate"
```

> Note: You will have to specify your own storage account name for where to store the Terraform state. Also don't forget to create your container name which in this instance is k8s-tfstate.

3. Create an execution plan and save the generated plan to a file.

```sh
terraform plan -out plan
```

4. Apply the changes only for the server and client applications

```sh
terraform apply -target azuread_service_principal.server -target azuread_service_principal.client
```

> Now go on the Azure Portal and Grant admin consent manually on both applications (the `k8s_server_${prefix}`, then the `k8s_client_${prefix}`).

5. Apply the remainder of changes required to reach desired state.

```sh
terraform plan -out plan
terraform apply plan
```

6. KubeConfig

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
prefix                     = "department"
short_prefix               = "dept"
environment                = "aks"
kube_version               = "1.16.15"
location                   = "Canada Central"
georeplication_region      = "Canada East"
admin_username             = "azureuser"
node_count                 = 2
node_size                  = "Standard_D4s_v3"
node_pod_count             = 60
public_ssh_key_path        = "~/.ssh/k8s.pub"
subscription_id            = ""
tenant_id                  = ""
load_balancer_sku          = "Standard"
load_balancer_outbound_ips = ["/subscriptions/XXXXX/resourceGroups/XXXXX/providers/Microsoft.Network/publicIPAddresses/XXXXX"]
```

## Variables Values

| Name                       | Type   | Required | Value                                                                                    |
| -------------------------- | ------ | -------- | ---------------------------------------------------------------------------------------- |
| prefix                     | string | yes      | A prefix used for all resources in this example                                          |
| short_prefix               | string | yes      | A short prefix used for all resources in this example                                    |
| kube_version               | string | yes      | Kubernetes version                                                                       |
| environment                | string | yes      | Environment name to be used when tagging resources                                       |
| location                   | string | yes      | The Azure Region in which all resources in this example should be provisioned            |
| georeplication_region      | string | yes      | The Azure Region to replicate georeplicated resources                                    |
| admin_username             | string | yes      | Admin username for cluster nodes                                                         |
| public_ssh_key_path        | string | yes      | The Path at which your Public SSH Key is located. Defaults to ~/.ssh/k8s                 |
| node_count                 | number | yes      | Number of Kubernetes worker nodes                                                        |
| node_size                  | string | yes      | VM Size for each Kubernetes worker node                                                  |
| node_disk_size             | number | yes      | Size of disk for the Kubernetes nodes (in GB)                                            |
| node_pod_count             | number | yes      | Number of pods per Kubernetes node                                                       |
| gpu_node_size              | number | yes      | GPU VM Size for each Kubernetes worker node                                              |
| gpu_node_count             | number | yes      | Number of GPU nodepool per Kubernetes cluster                                            |
| network_plugin             | string | yes      | Kubernetes networking plugin                                                             |
| network_policy             | string | yes      | Kubernetes policy plugin                                                                 |
| docker_bridge_cidr         | string | yes      | Docker bridge CIDR                                                                       |
| dns_service_ip             | string | yes      | DNS Service IP                                                                           |
| service_cidr               | string | yes      | Service CIDR                                                                             |
| vnet_cidr                  | string | yes      | Virtual Network CIDR                                                                     |
| subnet_cidr                | string | yes      | Container Subnet CIDR                                                                    |
| load_balancer_sku          | string | yes      | Load Balancer SKU                                                                        |
| load_balancer_outbound_ips | string | yes      | Load Balancer outbound ips                                                               |
| subscription_id            | string | yes      | The Subscription ID for the Service Principal to use for this Managed Kubernetes Cluster |
| tenant_id                  | string | yes      | The Tenant ID for the Service Principal to use for this Managed Kubernetes Cluster       |

## History

| Date     | Release    | Change                                                     |
| -------- | ---------- | ---------------------------------------------------------- |
| 20200606 | 20200606.1 | Updates to the AKS Cluster spec                            |
| 20201020 | 20201020.1 | Updates to the AKS Cluster spec                            |
| 20201025 | 20201025.1 | Updates to the AKS Cluster spec                            |
