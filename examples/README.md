# AKS + ACR Module Examples

This directory contains examples demonstrating how to use the Azure Kubernetes Service (AKS) + Azure Container Registry (ACR) Terraform module.

## 📁 Examples Overview

### Basic Example (`basic/`)
A minimal deployment example that demonstrates the core functionality of the module.

**Features:**
- Basic AKS cluster with default node pool
- Azure Container Registry with Standard SKU
- AKS-ACR integration for pulling images
- System-assigned managed identity
- Basic networking configuration

**Use Case:** Development environments, proof of concepts, or learning purposes.

### Advanced Example (`advanced/`)
A comprehensive enterprise-grade deployment example with advanced features.

**Features:**
- AKS cluster with multiple node pools (system, user, spot)
- Azure Container Registry with Premium SKU and encryption
- Azure AD RBAC integration
- Azure Monitor and Log Analytics integration
- Azure Policy and Key Vault Secrets Provider
- Private cluster with network security
- Workload Identity and OIDC issuer
- Advanced networking with custom subnets
- Maintenance windows and auto-scaling profiles

**Use Case:** Production environments, enterprise deployments, or when advanced features are required.

## 🚀 Getting Started

### Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform**: Install Terraform >= 1.0
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # or use package manager
   ```

3. **Required Permissions**: Ensure your Azure account has the following permissions:
   - Contributor role on the target subscription
   - Ability to create resource groups
   - Ability to create and manage AKS clusters
   - Ability to create and manage Azure Container Registry
   - (For advanced example) Azure AD permissions for RBAC

### Quick Start with Basic Example

1. **Navigate to the basic example directory:**
   ```bash
   cd examples/basic
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Get AKS credentials:**
   ```bash
   az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
   ```

6. **Verify the deployment:**
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

### Advanced Example Setup

1. **Navigate to the advanced example directory:**
   ```bash
   cd examples/advanced
   ```

2. **Customize the configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Update the Azure AD group reference:**
   - Replace `"AKS-Admins"` in `main.tf` with your actual Azure AD group name
   - Ensure the group exists and you have access to it

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 🔧 Customization

### Basic Example Customization

The basic example can be customized by modifying the variables in `main.tf`:

```hcl
module "aks_acr" {
  source = "../../"
  
  # Customize these values
  resource_group_name = "my-custom-rg"
  location            = "West US 2"
  environment         = "staging"
  
  # ACR Configuration
  acr_name = "mycustomacr"
  acr_sku  = "Premium"  # Upgrade to Premium for advanced features
  
  # AKS Configuration
  aks_name               = "my-custom-aks"
  aks_dns_prefix         = "mycustomaks"
  aks_kubernetes_version = "1.28.0"
  
  # Node Pool Configuration
  default_node_pool_vm_size = "Standard_DS3_v2"  # Larger VM size
  default_node_pool_node_count = 3               # More nodes
  default_node_pool_min_count  = 2
  default_node_pool_max_count  = 5
}
```

### Advanced Example Customization

The advanced example provides extensive customization options through variables:

1. **Edit `variables.tf`** to add or modify variables
2. **Edit `terraform.tfvars`** to set specific values
3. **Modify `main.tf`** to add additional resources or change configurations

Example customizations:

```hcl
# Add more node pools
additional_node_pools = [
  {
    name                    = "gpu"
    vm_size                 = "Standard_NC6s_v3"
    node_count              = 1
    min_count              = 0
    max_count              = 2
    enable_auto_scaling    = true
    node_labels = {
      "accelerator" = "nvidia"
    }
    node_taints = [
      "nvidia.com/gpu=true:NoSchedule"
    ]
  }
]

# Customize networking
aks_network_plugin = "azure"
aks_network_policy = "calico"  # Use Calico for advanced network policies

# Add monitoring
log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
enable_oms_agent = true
enable_azure_policy = true
```

## 🧹 Cleanup

To destroy the resources created by the examples:

```bash
# For basic example
cd examples/basic
terraform destroy

# For advanced example
cd examples/advanced
terraform destroy
```

**⚠️ Warning**: This will permanently delete all resources created by the example, including:
- AKS cluster and all node pools
- Azure Container Registry and all images
- Virtual network and subnets
- Log Analytics workspace
- All associated resources

## 🔍 Troubleshooting

### Common Issues

1. **ACR Name Already Exists**
   ```bash
   # Use a unique name or add random suffix
   acr_name = "myacr${random_string.suffix.result}"
   ```

2. **Insufficient Quotas**
   ```bash
   # Check current quotas
   az vm list-usage --location "East US" --output table
   
   # Request quota increase if needed
   az vm list-usage --location "East US" --query "[?name.value=='standardDSv2Family']"
   ```

3. **Azure AD Group Not Found**
   ```bash
   # List available groups
   az ad group list --display-name "*AKS*" --output table
   
   # Create group if needed
   az ad group create --display-name "AKS-Admins" --mail-nickname "AKS-Admins"
   ```

4. **Network Connectivity Issues**
   ```bash
   # Check VNet configuration
   az network vnet show --name <vnet-name> --resource-group <rg-name>
   
   # Verify subnet configuration
   az network vnet subnet show --name <subnet-name> --vnet-name <vnet-name> --resource-group <rg-name>
   ```

### Debugging Commands

```bash
# Check AKS cluster status
az aks show --resource-group <rg-name> --name <aks-name>

# Get cluster credentials
az aks get-credentials --resource-group <rg-name> --name <aks-name>

# Check node status
kubectl get nodes -o wide

# Check pod status
kubectl get pods --all-namespaces

# Check ACR connectivity
az acr login --name <acr-name>

# List ACR repositories
az acr repository list --name <acr-name>

# Check network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <acr-login-server>
```

## 📚 Next Steps

After successfully deploying the examples:

1. **Deploy Applications**: Use the AKS cluster to deploy your containerized applications
2. **Push Images**: Build and push Docker images to the ACR
3. **Configure CI/CD**: Set up automated deployment pipelines
4. **Monitor**: Configure additional monitoring and alerting
5. **Scale**: Adjust node pools and auto-scaling based on workload requirements

## 🤝 Contributing

To contribute new examples or improve existing ones:

1. Create a new directory for your example
2. Include a `main.tf` file with the module configuration
3. Add a `README.md` explaining the example's purpose and usage
4. Include any necessary supporting files (variables, outputs, etc.)
5. Test the example thoroughly before submitting

## 📞 Support

For issues with the examples:
- Check the troubleshooting section above
- Review the main module documentation
- Create an issue in the repository with detailed information about your problem 