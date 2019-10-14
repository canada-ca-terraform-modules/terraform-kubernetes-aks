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

## History

| Date     | Release    | Change      |
| -------- | ---------- | ----------- |
| 20190909 | 20190909.1 | 1st release |
