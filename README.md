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

> Note: If you're authenticating using a Service Principal (client_id) then it must have permissions to both Read and write all applications and Sign in and read user profile within the Windows Azure Active Directory API. See here how to add the required permissions: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis#add-permissions-to-access-web-apis

2. Ensure you have exported the `ARM_ACCESS_KEY` for the Terraform backend storage account.

```sh
export ARM_ACCESS_KEY=<secret>
```

3. Initialize and set the Terraform backend configuration parameters for the AzureRM provider.

```sh
terraform init\
    -backend-config="storage_account_name=terraformkubernetes" \
    -backend-config="container_name=k8s-tfstate" \
    -backend-config="key=prefix-aks.terraform.tfstate"
```

4. Create an execution plan and save the generated plan to a file.

```sh
terraform plan -out plan
```

5. Apply the changes required to reach desired state using the previous execution plan.

```sh
terraform apply plan
```

6. Grant admin consent for `k8s_server_prefix` for the organization under API permissions.

7. Admin level AKS credentials to assign further RBAC.

```sh
az aks get-credentials --resource-group op-aks --name op-aks --admin --overwrite-existing
```

8. Export the user level kubeconfig context

```sh
terraform output kube_config > kubeconfig
```

## History

| Date     | Release    | Change      |
| -------- | ---------- | ----------- |
| 20190909 | 20190909.1 | 1st release |
