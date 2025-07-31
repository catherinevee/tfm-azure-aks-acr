# ==============================================================================
# Advanced AKS + ACR Example
# ==============================================================================
# This example demonstrates an advanced deployment of Azure Kubernetes Service (AKS)
# with Azure Container Registry (ACR) integration, including enterprise-grade features.
# 
# Features included:
# - AKS cluster with multiple node pools (system, user, spot)
# - Azure Container Registry with Premium SKU and encryption
# - Azure AD RBAC integration
# - Azure Monitor and Log Analytics integration
# - Azure Policy and Key Vault Secrets Provider
# - Private cluster with network security
# - Workload Identity and OIDC issuer
# - Advanced networking with custom subnets
# - Maintenance windows and auto-scaling profiles
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Configure the Azure AD Provider
provider "azuread" {
  # Azure AD provider configuration
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-acr-advanced-example"
  location = "East US"
  
  tags = {
    Environment = "prod"
    Project     = "aks-acr-advanced"
    ManagedBy   = "Terraform"
  }
}

# Create Virtual Network and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-acr-advanced"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    Environment = "prod"
    Project     = "aks-acr-advanced"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  
  # Enable service endpoints for AKS
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "acr_subnet" {
  name                 = "snet-acr"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  
  # Enable service endpoints for ACR
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

# Create Log Analytics Workspace for Monitoring
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "law-aks-acr-advanced"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    Environment = "prod"
    Project     = "aks-acr-advanced"
  }
}

# Create Azure AD Group for AKS Admins (example)
data "azuread_group" "aks_admins" {
  display_name = "AKS-Admins"  # Replace with your actual AD group name
}

# Deploy AKS + ACR Module
module "aks_acr" {
  source = "../../"
  
  # General Configuration
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  environment         = "prod"
  project             = "aks-acr-advanced"
  
  # ACR Configuration
  acr_name = "acradvanced${random_string.suffix.result}"
  acr_sku  = "Premium"
  
  # ACR Advanced Features
  acr_admin_enabled = false
  acr_public_network_access_enabled = false
  
  # ACR Network Rules
  acr_network_rule_set = [
    {
      subnet_id = azurerm_subnet.acr_subnet.id
      action    = "Allow"
      virtual_network_subnet_id = azurerm_subnet.acr_subnet.id
    }
  ]
  
  # ACR Retention Policy
  acr_retention_policy = {
    days    = 30
    enabled = true
  }
  
  # ACR Trust Policy
  acr_trust_policy = {
    enabled = true
  }
  
  # AKS Configuration
  aks_name                = "aks-advanced-example"
  aks_dns_prefix          = "aks-advanced"
  aks_kubernetes_version  = "1.28.0"
  aks_sku_tier            = "Paid"
  
  # AKS Identity
  aks_identity_type = "SystemAssigned"
  
  # Default Node Pool Configuration (System Pool)
  default_node_pool_name = "system"
  default_node_pool_vm_size = "Standard_DS3_v2"
  default_node_pool_node_count = 2
  default_node_pool_min_count  = 2
  default_node_pool_max_count  = 4
  default_node_pool_enable_auto_scaling = true
  default_node_pool_max_pods = 110
  default_node_pool_os_disk_size_gb = 128
  default_node_pool_os_disk_type = "Managed"
  default_node_pool_os_sku = "Ubuntu"
  default_node_pool_subnet_id = azurerm_subnet.aks_subnet.id
  default_node_pool_zones = ["1", "2", "3"]
  default_node_pool_ultra_ssd_enabled = false
  default_node_pool_scale_down_mode = "Delete"
  
  # Node Labels and Taints for System Pool
  default_node_pool_node_labels = {
    "node.kubernetes.io/role" = "system"
    "kubernetes.azure.com/node-pool-type" = "system"
  }
  default_node_pool_node_taints = [
    "kubernetes.azure.com/system=true:NoSchedule"
  ]
  
  # Network Configuration
  aks_network_plugin = "azure"
  aks_network_policy = "azure"
  aks_pod_cidr       = "10.244.0.0/16"
  aks_service_cidr   = "10.0.0.0/16"
  aks_dns_service_ip = "10.0.0.10"
  aks_outbound_type  = "loadBalancer"
  aks_load_balancer_sku = "standard"
  
  # Private Cluster Configuration
  aks_private_cluster_enabled = true
  
  # API Server Authorized IP Ranges
  aks_api_server_authorized_ip_ranges = [
    "10.0.0.0/8",  # Replace with your actual IP ranges
    "192.168.0.0/16"
  ]
  
  # RBAC Configuration
  rbac_enabled = true
  local_account_disabled = true
  
  # Azure AD RBAC Configuration
  azure_active_directory_role_based_access_control = {
    managed                = true
    tenant_id              = data.azuread_group.aks_admins.tenant_id
    admin_group_object_ids = [data.azuread_group.aks_admins.object_id]
    azure_rbac_enabled     = true
  }
  
  # Monitoring Configuration
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enable_oms_agent = true
  
  # Azure Policy
  enable_azure_policy = true
  
  # Key Vault Secrets Provider
  enable_azure_key_vault_secrets_provider = true
  key_vault_secrets_provider_secret_rotation_enabled = true
  key_vault_secrets_provider_secret_rotation_interval = "2m"
  
  # Workload Identity
  aks_workload_identity_enabled = true
  
  # OIDC Issuer
  aks_oidc_issuer_enabled = true
  
  # Additional Node Pools
  additional_node_pools = [
    {
      # User Node Pool
      name                    = "user"
      vm_size                 = "Standard_DS4_v2"
      node_count              = 3
      min_count              = 2
      max_count              = 6
      enable_auto_scaling    = true
      enable_host_encryption = false
      enable_node_public_ip  = false
      max_pods               = 110
      node_taints            = []
      node_labels = {
        "node.kubernetes.io/role" = "user"
        "kubernetes.azure.com/node-pool-type" = "user"
      }
      os_disk_size_gb        = 128
      os_disk_type           = "Managed"
      os_sku                 = "Ubuntu"
      subnet_id              = azurerm_subnet.aks_subnet.id
      zones                  = ["1", "2", "3"]
      ultra_ssd_enabled      = false
      scale_down_mode        = "Delete"
      mode                   = "User"
      priority               = "Regular"
      eviction_policy        = "Delete"
    },
    {
      # Spot Node Pool for cost optimization
      name                    = "spot"
      vm_size                 = "Standard_DS3_v2"
      node_count              = 2
      min_count              = 1
      max_count              = 4
      enable_auto_scaling    = true
      enable_host_encryption = false
      enable_node_public_ip  = false
      max_pods               = 110
      node_taints            = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      node_labels = {
        "node.kubernetes.io/role" = "spot"
        "kubernetes.azure.com/node-pool-type" = "spot"
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      os_disk_size_gb        = 128
      os_disk_type           = "Managed"
      os_sku                 = "Ubuntu"
      subnet_id              = azurerm_subnet.aks_subnet.id
      zones                  = ["1", "2", "3"]
      ultra_ssd_enabled      = false
      scale_down_mode        = "Delete"
      mode                   = "User"
      priority               = "Spot"
      eviction_policy        = "Delete"
      spot_max_price         = 0.5
    }
  ]
  
  # Maintenance Window
  maintenance_window = {
    allowed = [
      {
        day   = "Sunday"
        hours = [0, 1, 2, 3, 4, 5, 6]
      }
    ]
    not_allowed = [
      {
        start = "2024-01-01T00:00:00Z"
        end   = "2024-01-02T00:00:00Z"
      }
    ]
  }
  
  # Cluster Auto Scaler Profile
  cluster_autoscaler_profile = {
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded             = "10m"
    scale_down_unready              = "20m"
    max_node_provision_time         = "15m"
    balance_similar_node_groups     = false
    expander                        = "random"
    skip_nodes_with_local_storage   = true
    skip_nodes_with_system_pods     = true
    max_graceful_termination_sec    = "600"
    scale_down_utilization_threshold = "0.5"
    new_pod_scale_up_delay          = "10s"
    max_total_unready_percentage    = "45"
    ok_total_unready_count          = "3"
  }
  
  # Tags
  tags = {
    Example = "advanced"
    Purpose = "enterprise-demonstration"
    CostCenter = "IT-001"
    Owner = "Platform Team"
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ==============================================================================
# Outputs
# ==============================================================================

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks_acr.aks_name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks_acr.aks_fqdn
}

output "aks_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = module.aks_acr.aks_private_fqdn
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.aks_acr.acr_name
}

output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = module.aks_acr.acr_login_server
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "additional_node_pool_names" {
  description = "The names of the additional node pools"
  value       = module.aks_acr.additional_node_pool_names
}

output "kube_config_command" {
  description = "Command to get kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks_acr.aks_name}"
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for the AKS cluster"
  value       = module.aks_acr.aks_oidc_issuer_url
} 