# ==============================================================================
# Basic AKS + ACR Example
# ==============================================================================
# This example demonstrates a basic deployment of Azure Kubernetes Service (AKS)
# with Azure Container Registry (ACR) integration.
# 
# Features included:
# - Basic AKS cluster with default node pool
# - Azure Container Registry with Standard SKU
# - AKS-ACR integration for pulling images
# - System-assigned managed identity
# - Basic networking configuration
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-acr-basic-example"
  location = "East US"
  
  tags = {
    Environment = "dev"
    Project     = "aks-acr-example"
    ManagedBy   = "Terraform"
  }
}

# Deploy AKS + ACR Module
module "aks_acr" {
  source = "../../"
  
  # General Configuration
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  environment         = "dev"
  project             = "aks-acr-example"
  
  # ACR Configuration
  acr_name = "acrbasic${random_string.suffix.result}"
  acr_sku  = "Standard"
  
  # AKS Configuration
  aks_name                = "aks-basic-example"
  aks_dns_prefix          = "aks-basic"
  aks_kubernetes_version  = "1.28.0"
  aks_sku_tier            = "Free"
  
  # Default Node Pool Configuration
  default_node_pool_vm_size = "Standard_DS2_v2"
  default_node_pool_node_count = 2
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 3
  
  # Network Configuration
  aks_network_plugin = "azure"
  aks_network_policy = "azure"
  aks_pod_cidr       = "10.244.0.0/16"
  aks_service_cidr   = "10.0.0.0/16"
  aks_dns_service_ip = "10.0.0.10"
  
  # RBAC Configuration
  rbac_enabled = true
  
  # Monitoring Configuration
  enable_oms_agent = true
  
  # Tags
  tags = {
    Example = "basic"
    Purpose = "demonstration"
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

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks_acr.aks_name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks_acr.aks_fqdn
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.aks_acr.acr_name
}

output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = module.aks_acr.acr_login_server
}

output "kube_config_command" {
  description = "Command to get kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks_acr.aks_name}"
} 