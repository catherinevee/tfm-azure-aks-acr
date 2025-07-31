# Azure Kubernetes Service (AKS) + Azure Container Registry (ACR) Terraform Module

A comprehensive Terraform module for deploying Azure Kubernetes Service (AKS) with Azure Container Registry (ACR) integration, designed for enterprise-grade Kubernetes deployments on Azure.

## 🚀 Features

### Azure Container Registry (ACR)
- **Multiple SKUs**: Basic, Standard, and Premium tiers
- **Network Security**: Private endpoints, network rules, and VNet integration
- **Content Trust**: Image signing and verification
- **Retention Policies**: Automated image lifecycle management
- **Encryption**: Customer-managed keys (Premium SKU)
- **Geographic Replication**: Multi-region deployment (Premium SKU)

### Azure Kubernetes Service (AKS)
- **Multiple Node Pools**: System, user, and spot instance pools
- **Auto-scaling**: Horizontal and vertical pod autoscaling
- **Identity Management**: System-assigned and user-assigned managed identities
- **Azure AD Integration**: RBAC with Azure Active Directory
- **Network Security**: Private clusters, network policies, and API server access control
- **Monitoring**: Azure Monitor and Log Analytics integration
- **Security**: Azure Policy, Key Vault Secrets Provider, and Workload Identity
- **Maintenance**: Scheduled maintenance windows and automatic updates

### Advanced Features
- **Multi-zone Deployment**: High availability across availability zones
- **Spot Instances**: Cost optimization with spot node pools
- **Custom Networking**: VNet integration with custom subnets
- **OIDC Integration**: OpenID Connect for external identity providers
- **Cluster Auto-scaler**: Intelligent node scaling based on workload demands

## 📋 Prerequisites

- Terraform >= 1.0
- Azure CLI configured with appropriate permissions
- Azure subscription with sufficient quotas
- (Optional) Azure AD tenant for RBAC integration

## 🏗️ Module Structure

```
tfm-azure-aks-acr/
├── main.tf                 # Main module configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── locals.tf               # Local values and computed variables
├── versions.tf             # Provider and Terraform version constraints
├── README.md               # This file
└── examples/
    ├── basic/              # Basic deployment example
    │   └── main.tf
    └── advanced/           # Advanced deployment example
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars.example
```

## 🔧 Usage

### Basic Example

```hcl
module "aks_acr" {
  source = "path/to/tfm-azure-aks-acr"
  
  # General Configuration
  resource_group_name = "rg-my-aks-acr"
  location            = "East US"
  environment         = "dev"
  project             = "my-project"
  
  # ACR Configuration
  acr_name = "myacrregistry"
  acr_sku  = "Standard"
  
  # AKS Configuration
  aks_name               = "my-aks-cluster"
  aks_dns_prefix         = "myaks"
  aks_kubernetes_version = "1.28.0"
  
  # Default Node Pool
  default_node_pool_vm_size = "Standard_DS2_v2"
  default_node_pool_node_count = 2
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 3
  
  # Tags
  tags = {
    Environment = "dev"
    Owner       = "Platform Team"
  }
}
```

### Advanced Example

```hcl
module "aks_acr" {
  source = "path/to/tfm-azure-aks-acr"
  
  # General Configuration
  resource_group_name = "rg-my-aks-acr"
  location            = "East US"
  environment         = "prod"
  project             = "my-enterprise-project"
  
  # ACR Configuration
  acr_name = "myenterpriseacr"
  acr_sku  = "Premium"
  
  # ACR Advanced Features
  acr_admin_enabled = false
  acr_public_network_access_enabled = false
  acr_network_rule_set = [
    {
      subnet_id = azurerm_subnet.acr_subnet.id
      action    = "Allow"
      virtual_network_subnet_id = azurerm_subnet.acr_subnet.id
    }
  ]
  
  # AKS Configuration
  aks_name               = "my-enterprise-aks"
  aks_dns_prefix         = "myenterpriseaks"
  aks_kubernetes_version = "1.28.0"
  aks_sku_tier           = "Paid"
  
  # Identity
  aks_identity_type = "SystemAssigned"
  
  # Private Cluster
  aks_private_cluster_enabled = true
  aks_api_server_authorized_ip_ranges = ["10.0.0.0/8"]
  
  # Azure AD RBAC
  azure_active_directory_role_based_access_control = {
    managed                = true
    tenant_id              = "your-tenant-id"
    admin_group_object_ids = ["your-admin-group-id"]
    azure_rbac_enabled     = true
  }
  
  # Additional Node Pools
  additional_node_pools = [
    {
      name                    = "user"
      vm_size                 = "Standard_DS4_v2"
      node_count              = 3
      min_count              = 2
      max_count              = 6
      enable_auto_scaling    = true
      node_labels = {
        "node.kubernetes.io/role" = "user"
      }
    },
    {
      name                    = "spot"
      vm_size                 = "Standard_DS3_v2"
      node_count              = 2
      min_count              = 1
      max_count              = 4
      enable_auto_scaling    = true
      priority               = "Spot"
      spot_max_price         = 0.5
      node_taints            = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
    }
  ]
  
  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enable_oms_agent = true
  enable_azure_policy = true
  
  # Security
  enable_azure_key_vault_secrets_provider = true
  aks_workload_identity_enabled = true
  aks_oidc_issuer_enabled = true
}
```

## 📖 Inputs

### General Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for resources | `string` | `"East US"` | no |
| environment | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| project | Project name for tagging | `string` | `"aks-acr"` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

### Azure Container Registry (ACR)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acr_name | Name of the Azure Container Registry | `string` | n/a | yes |
| acr_sku | SKU of the ACR (Basic, Standard, Premium) | `string` | `"Standard"` | no |
| acr_admin_enabled | Enable admin user for ACR | `bool` | `false` | no |
| acr_public_network_access_enabled | Enable public network access | `bool` | `true` | no |
| acr_network_rule_set | Network rule set for ACR | `list(object)` | `[]` | no |
| acr_retention_policy | Retention policy configuration | `object` | `{days = 7, enabled = true}` | no |
| acr_trust_policy | Trust policy configuration | `object` | `{enabled = false}` | no |
| acr_encryption | Encryption settings | `object` | `{enabled = false}` | no |

### Azure Kubernetes Service (AKS)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aks_name | Name of the AKS cluster | `string` | n/a | yes |
| aks_dns_prefix | DNS prefix for AKS | `string` | n/a | yes |
| aks_kubernetes_version | Kubernetes version | `string` | `"1.28.0"` | no |
| aks_sku_tier | SKU tier (Free, Paid) | `string` | `"Free"` | no |
| aks_identity_type | Identity type (SystemAssigned, UserAssigned) | `string` | `"SystemAssigned"` | no |
| aks_private_cluster_enabled | Enable private cluster | `bool` | `false` | no |
| aks_api_server_authorized_ip_ranges | Authorized IP ranges | `list(string)` | `[]` | no |

### Node Pool Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default_node_pool_vm_size | VM size for default node pool | `string` | `"Standard_DS2_v2"` | no |
| default_node_pool_node_count | Number of nodes | `number` | `1` | no |
| default_node_pool_min_count | Minimum node count | `number` | `1` | no |
| default_node_pool_max_count | Maximum node count | `number` | `3` | no |
| additional_node_pools | Additional node pools configuration | `list(object)` | `[]` | no |

### Networking

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aks_network_plugin | Network plugin (azure, kubenet) | `string` | `"azure"` | no |
| aks_network_policy | Network policy (azure, calico) | `string` | `"azure"` | no |
| aks_pod_cidr | Pod CIDR | `string` | `"10.244.0.0/16"` | no |
| aks_service_cidr | Service CIDR | `string` | `"10.0.0.0/16"` | no |
| aks_dns_service_ip | DNS service IP | `string` | `"10.0.0.10"` | no |

### Security and RBAC

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| rbac_enabled | Enable RBAC | `bool` | `true` | no |
| local_account_disabled | Disable local accounts | `bool` | `false` | no |
| azure_active_directory_role_based_access_control | Azure AD RBAC configuration | `object` | `{managed = false}` | no |

### Monitoring and Logging

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| log_analytics_workspace_id | Log Analytics workspace ID | `string` | `null` | no |
| enable_oms_agent | Enable OMS agent | `bool` | `true` | no |
| enable_azure_policy | Enable Azure Policy | `bool` | `false` | no |
| enable_azure_key_vault_secrets_provider | Enable Key Vault Secrets Provider | `bool` | `false` | no |

## 📤 Outputs

### ACR Outputs

| Name | Description |
|------|-------------|
| acr_id | The ID of the Azure Container Registry |
| acr_name | The name of the Azure Container Registry |
| acr_login_server | The login server URL of the Azure Container Registry |
| acr_admin_username | The admin username for the Azure Container Registry |
| acr_admin_password | The admin password for the Azure Container Registry |
| acr_sku | The SKU of the Azure Container Registry |

### AKS Outputs

| Name | Description |
|------|-------------|
| aks_id | The ID of the Azure Kubernetes Service cluster |
| aks_name | The name of the Azure Kubernetes Service cluster |
| aks_fqdn | The FQDN of the Azure Kubernetes Service cluster |
| aks_private_fqdn | The private FQDN of the Azure Kubernetes Service cluster |
| aks_kubernetes_version | The Kubernetes version of the Azure Kubernetes Service cluster |
| aks_oidc_issuer_url | The OIDC issuer URL of the Azure Kubernetes Service cluster |

### Kubernetes Configuration

| Name | Description |
|------|-------------|
| kube_config_raw | The raw Kubernetes configuration |
| kube_config | The Kubernetes configuration object |
| kube_config_host | The Kubernetes cluster host |

### Additional Resources

| Name | Description |
|------|-------------|
| additional_node_pool_names | The names of the additional node pools |
| additional_node_pool_ids | The IDs of the additional node pools |
| aks_user_assigned_identity_id | The ID of the user assigned identity for AKS |

## 🔒 Security Best Practices

### Network Security
- Use private clusters for production workloads
- Configure API server authorized IP ranges
- Implement network policies for pod-to-pod communication
- Use private endpoints for ACR access

### Identity and Access Management
- Use managed identities instead of service principals
- Implement Azure AD RBAC for cluster access
- Enable workload identity for pod authentication
- Use OIDC for external identity providers

### Container Security
- Enable content trust for image signing
- Implement image scanning and vulnerability assessment
- Use retention policies for image lifecycle management
- Configure network rules for ACR access

### Monitoring and Compliance
- Enable Azure Monitor and Log Analytics
- Implement Azure Policy for compliance
- Use Key Vault Secrets Provider for secret management
- Configure audit logging for all resources

## 💰 Cost Optimization

### Node Pool Strategies
- Use spot instances for non-critical workloads
- Implement proper auto-scaling policies
- Right-size VM instances based on workload requirements
- Use availability zones for high availability

### Storage Optimization
- Configure appropriate retention policies for ACR
- Use appropriate ACR SKU based on requirements
- Implement lifecycle management for container images

### Resource Management
- Use appropriate tags for cost allocation
- Implement resource quotas and limits
- Monitor and optimize resource usage regularly

## 🚨 Troubleshooting

### Common Issues

1. **ACR Name Already Exists**
   - ACR names must be globally unique
   - Use random suffixes or unique naming conventions

2. **Insufficient Quotas**
   - Check subscription quotas for VM cores
   - Request quota increases if needed

3. **Network Connectivity Issues**
   - Verify VNet and subnet configurations
   - Check network security group rules
   - Ensure proper DNS resolution

4. **Authentication Issues**
   - Verify Azure AD group membership
   - Check RBAC role assignments
   - Ensure proper service principal permissions

### Debugging Commands

```bash
# Get AKS credentials
az aks get-credentials --resource-group <rg-name> --name <aks-name>

# Check node status
kubectl get nodes

# Check pod status
kubectl get pods --all-namespaces

# Check ACR connectivity
az acr login --name <acr-name>

# View AKS logs
az aks show --resource-group <rg-name> --name <aks-name> --query "addonProfiles"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This module is licensed under the MIT License. See the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Azure documentation for AKS and ACR

## 🔗 Related Resources

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [ACR Best Practices](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-best-practices)