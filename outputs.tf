# ==============================================================================
# Azure Container Registry (ACR) Outputs
# ==============================================================================

output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "The admin username for the Azure Container Registry (if admin enabled)"
  value       = var.acr_admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "acr_admin_password" {
  description = "The admin password for the Azure Container Registry (if admin enabled)"
  value       = var.acr_admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}

output "acr_sku" {
  description = "The SKU of the Azure Container Registry"
  value       = azurerm_container_registry.acr.sku
}

output "acr_public_network_access_enabled" {
  description = "Whether public network access is enabled for the Azure Container Registry"
  value       = azurerm_container_registry.acr.public_network_access_enabled
}

# ==============================================================================
# Azure Kubernetes Service (AKS) Outputs
# ==============================================================================

output "aks_id" {
  description = "The ID of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "The name of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group_name" {
  description = "The resource group name of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "aks_location" {
  description = "The location of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.location
}

output "aks_kubernetes_version" {
  description = "The Kubernetes version of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "aks_dns_prefix" {
  description = "The DNS prefix of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.dns_prefix
}

output "aks_fqdn" {
  description = "The FQDN of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_private_fqdn" {
  description = "The private FQDN of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "aks_private_cluster_enabled" {
  description = "Whether private cluster is enabled for the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.private_cluster_enabled
}

output "aks_network_profile" {
  description = "The network profile of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.network_profile
}

output "aks_default_node_pool" {
  description = "The default node pool configuration of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool
}

output "aks_identity" {
  description = "The identity configuration of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.identity
  sensitive   = true
}

output "aks_kubelet_identity" {
  description = "The kubelet identity of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
  sensitive   = true
}

output "aks_service_principal" {
  description = "The service principal configuration of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.service_principal
  sensitive   = true
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

# ==============================================================================
# Kubernetes Configuration Outputs
# ==============================================================================

output "kube_config_raw" {
  description = "The raw Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "The Kubernetes configuration object"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "kube_config_host" {
  description = "The Kubernetes cluster host"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "kube_config_username" {
  description = "The Kubernetes cluster username"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.username
  sensitive   = true
}

output "kube_config_password" {
  description = "The Kubernetes cluster password"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.password
  sensitive   = true
}

output "kube_config_client_certificate" {
  description = "The Kubernetes cluster client certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "kube_config_client_key" {
  description = "The Kubernetes cluster client key"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "kube_config_cluster_ca_certificate" {
  description = "The Kubernetes cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

# ==============================================================================
# Additional Node Pools Outputs
# ==============================================================================

output "additional_node_pools" {
  description = "The additional node pools of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster_node_pool.additional_pools
}

output "additional_node_pool_names" {
  description = "The names of the additional node pools"
  value       = [for pool in azurerm_kubernetes_cluster_node_pool.additional_pools : pool.name]
}

output "additional_node_pool_ids" {
  description = "The IDs of the additional node pools"
  value       = [for pool in azurerm_kubernetes_cluster_node_pool.additional_pools : pool.id]
}

# ==============================================================================
# Role Assignment Outputs
# ==============================================================================

output "aks_acr_pull_role_assignment_id" {
  description = "The ID of the AKS-ACR pull role assignment"
  value       = var.acr_admin_enabled ? null : azurerm_role_assignment.aks_acr_pull[0].id
}

output "aks_acr_push_role_assignment_id" {
  description = "The ID of the AKS-ACR push role assignment"
  value       = var.acr_admin_enabled ? null : azurerm_role_assignment.aks_acr_push[0].id
}

# ==============================================================================
# User Assigned Identity Outputs
# ==============================================================================

output "aks_user_assigned_identity_id" {
  description = "The ID of the user assigned identity for AKS"
  value       = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].id : null
}

output "aks_user_assigned_identity_principal_id" {
  description = "The principal ID of the user assigned identity for AKS"
  value       = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].principal_id : null
}

output "aks_user_assigned_identity_client_id" {
  description = "The client ID of the user assigned identity for AKS"
  value       = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].client_id : null
}

# ==============================================================================
# Monitoring and Logging Outputs
# ==============================================================================

output "oms_agent_identity" {
  description = "The OMS agent identity of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.oms_agent
}

output "azure_policy_enabled" {
  description = "Whether Azure Policy is enabled for the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.azure_policy
}

output "key_vault_secrets_provider" {
  description = "The Key Vault Secrets Provider configuration of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider
}

# ==============================================================================
# Network and Security Outputs
# ==============================================================================

output "api_server_authorized_ip_ranges" {
  description = "The API server authorized IP ranges of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.api_server_authorized_ip_ranges
}

output "disk_encryption_set_id" {
  description = "The disk encryption set ID of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.disk_encryption_set_id
}

# ==============================================================================
# Maintenance and Auto Scaler Outputs
# ==============================================================================

output "maintenance_window" {
  description = "The maintenance window configuration of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.maintenance_window
}

output "cluster_autoscaler_profile" {
  description = "The cluster autoscaler profile of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.cluster_autoscaler_profile
}

# ==============================================================================
# Tags Output
# ==============================================================================

output "tags" {
  description = "The tags applied to all resources"
  value       = local.common_tags
} 