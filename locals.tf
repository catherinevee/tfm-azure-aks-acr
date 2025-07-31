# ==============================================================================
# Common Tags
# ==============================================================================

locals {
  # Common tags to be applied to all resources
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
      Module      = "aks-acr"
    },
    var.tags
  )

  # Name prefixes for resources
  name_prefix = "${var.project}-${var.environment}"
  
  # AKS cluster name
  aks_cluster_name = var.aks_name
  
  # ACR registry name
  acr_registry_name = var.acr_name
  
  # Default node pool name
  default_node_pool_name = var.default_node_pool_name
  
  # Resource group name
  resource_group_name = var.resource_group_name
  
  # Location
  location = var.location
}

# ==============================================================================
# Computed Values
# ==============================================================================

locals {
  # Determine if AKS should use managed identity
  use_managed_identity = var.aks_identity_type == "SystemAssigned" || var.aks_identity_type == "UserAssigned"
  
  # Determine if service principal should be used
  use_service_principal = var.service_principal != null
  
  # Determine if Azure AD RBAC is enabled
  azure_ad_rbac_enabled = var.azure_active_directory_role_based_access_control.managed
  
  # Determine if monitoring is enabled
  monitoring_enabled = var.log_analytics_workspace_id != null && var.enable_oms_agent
  
  # Determine if Azure Policy is enabled
  azure_policy_enabled = var.enable_azure_policy || var.aks_azure_policy_enabled
  
  # Determine if Key Vault Secrets Provider is enabled
  key_vault_secrets_provider_enabled = var.enable_azure_key_vault_secrets_provider || var.aks_key_vault_secrets_provider_enabled
  
  # Determine if workload identity is enabled
  workload_identity_enabled = var.aks_workload_identity_enabled
  
  # Determine if OIDC issuer is enabled
  oidc_issuer_enabled = var.aks_oidc_issuer_enabled
  
  # Determine if private cluster is enabled
  private_cluster_enabled = var.aks_private_cluster_enabled
  
  # Determine if HTTP application routing is enabled
  http_application_routing_enabled = var.aks_http_application_routing_enabled
  
  # Determine if Open Service Mesh is enabled
  open_service_mesh_enabled = var.aks_open_service_mesh_enabled
}

# ==============================================================================
# Validation Rules
# ==============================================================================

locals {
  # Validate that either managed identity or service principal is configured
  identity_validation = (
    local.use_managed_identity || local.use_service_principal
  ) ? null : file("ERROR: Either managed identity or service principal must be configured for AKS")
  
  # Validate ACR name uniqueness (basic check)
  acr_name_validation = (
    length(var.acr_name) >= 5 && length(var.acr_name) <= 50
  ) ? null : file("ERROR: ACR name must be between 5 and 50 characters")
  
  # Validate AKS name
  aks_name_validation = (
    length(var.aks_name) >= 1 && length(var.aks_name) <= 63
  ) ? null : file("ERROR: AKS name must be between 1 and 63 characters")
  
  # Validate DNS prefix
  dns_prefix_validation = (
    length(var.aks_dns_prefix) >= 1 && length(var.aks_dns_prefix) <= 54
  ) ? null : file("ERROR: DNS prefix must be between 1 and 54 characters")
} 