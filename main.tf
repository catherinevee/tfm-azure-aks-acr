# ==============================================================================
# Azure Container Registry (ACR)
# ==============================================================================

resource "azurerm_container_registry" "acr" {
  name                = local.acr_registry_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  # Network access settings
  public_network_access_enabled = var.acr_public_network_access_enabled

  # Network rule set
  dynamic "network_rule_set" {
    for_each = length(var.acr_network_rule_set) > 0 ? [1] : []
    content {
      default_action = "Deny"
      
      dynamic "virtual_network" {
        for_each = var.acr_network_rule_set
        content {
          subnet_id = virtual_network.value.subnet_id
          action    = virtual_network.value.action
        }
      }
    }
  }

  tags = local.common_tags
}

# ==============================================================================
# Azure Kubernetes Service (AKS) - Identity
# ==============================================================================

# User Assigned Identity (if specified)
resource "azurerm_user_assigned_identity" "aks_identity" {
  count               = var.aks_identity_type == "UserAssigned" ? 1 : 0
  name                = "${local.aks_cluster_name}-identity"
  resource_group_name = local.resource_group_name
  location            = local.location

  tags = local.common_tags
}

# ==============================================================================
# Azure Kubernetes Service (AKS) - Cluster
# ==============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.aks_kubernetes_version
  sku_tier            = var.aks_sku_tier

  # Identity configuration
  dynamic "identity" {
    for_each = local.use_managed_identity ? [1] : []
    content {
      type = var.aks_identity_type
      identity_ids = var.aks_identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.aks_identity[0].id] : null
    }
  }

  # Service principal configuration (if not using managed identity)
  dynamic "service_principal" {
    for_each = local.use_service_principal ? [1] : []
    content {
      client_id     = var.service_principal.client_id
      client_secret = var.service_principal.client_secret
    }
  }

  # Default node pool
  default_node_pool {
    name                = local.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    node_count          = var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count
    min_count           = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count           = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null
    max_pods            = var.default_node_pool_max_pods
    node_labels         = var.default_node_pool_node_labels
    os_disk_size_gb     = var.default_node_pool_os_disk_size_gb
    os_disk_type        = var.default_node_pool_os_disk_type
    os_sku              = var.default_node_pool_os_sku
    zones               = var.default_node_pool_zones
    ultra_ssd_enabled   = var.default_node_pool_ultra_ssd_enabled
  }

  # Network profile
  network_profile {
    network_plugin     = var.aks_network_plugin
    network_policy     = var.aks_network_policy
    pod_cidr           = var.aks_pod_cidr
    service_cidr       = var.aks_service_cidr
    dns_service_ip     = var.aks_dns_service_ip
    outbound_type      = var.aks_outbound_type
    load_balancer_sku  = var.aks_load_balancer_sku
  }

  # RBAC configuration
  role_based_access_control_enabled = var.rbac_enabled
  local_account_disabled            = var.local_account_disabled

  # Azure AD RBAC configuration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = local.azure_ad_rbac_enabled ? [1] : []
    content {
      managed                = var.azure_active_directory_role_based_access_control.managed
      tenant_id              = var.azure_active_directory_role_based_access_control.tenant_id
      admin_group_object_ids = var.azure_active_directory_role_based_access_control.admin_group_object_ids
      azure_rbac_enabled     = var.azure_active_directory_role_based_access_control.azure_rbac_enabled
    }
  }

  # Monitoring configuration
  dynamic "oms_agent" {
    for_each = local.monitoring_enabled ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Azure Policy configuration
  dynamic "azure_policy" {
    for_each = local.azure_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Key Vault Secrets Provider configuration
  dynamic "key_vault_secrets_provider" {
    for_each = local.key_vault_secrets_provider_enabled ? [1] : []
    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider_secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider_secret_rotation_interval
    }
  }

  # Workload Identity configuration
  dynamic "workload_identity" {
    for_each = local.workload_identity_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # OIDC issuer configuration
  dynamic "oidc_issuer" {
    for_each = local.oidc_issuer_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Private cluster configuration
  dynamic "private_cluster_enabled" {
    for_each = local.private_cluster_enabled ? [1] : []
    content {
      enabled = true
      private_dns_zone_id = var.aks_private_dns_zone_id
    }
  }

  # API server authorized IP ranges
  dynamic "api_server_authorized_ip_ranges" {
    for_each = length(var.aks_api_server_authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.aks_api_server_authorized_ip_ranges
    }
  }

  # Disk encryption set
  dynamic "disk_encryption_set_id" {
    for_each = var.aks_disk_encryption_set_id != null ? [1] : []
    content {
      disk_encryption_set_id = var.aks_disk_encryption_set_id
    }
  }

  # HTTP application routing
  dynamic "http_application_routing_enabled" {
    for_each = local.http_application_routing_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Open Service Mesh
  dynamic "open_service_mesh_enabled" {
    for_each = local.open_service_mesh_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [1] : []
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window.allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      
      dynamic "not_allowed" {
        for_each = var.maintenance_window.not_allowed != null ? var.maintenance_window.not_allowed : []
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  # Auto scaler profile
  dynamic "cluster_autoscaler_profile" {
    for_each = length(var.cluster_autoscaler_profile) > 0 ? [1] : []
    content {
      scale_down_delay_after_add       = var.cluster_autoscaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.cluster_autoscaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.cluster_autoscaler_profile.scale_down_delay_after_failure
      scan_interval                    = var.cluster_autoscaler_profile.scan_interval
      scale_down_unneeded             = var.cluster_autoscaler_profile.scale_down_unneeded
      scale_down_unready              = var.cluster_autoscaler_profile.scale_down_unready
      max_node_provision_time         = var.cluster_autoscaler_profile.max_node_provision_time
      balance_similar_node_groups     = var.cluster_autoscaler_profile.balance_similar_node_groups
      expander                        = var.cluster_autoscaler_profile.expander
      skip_nodes_with_local_storage   = var.cluster_autoscaler_profile.skip_nodes_with_local_storage
      skip_nodes_with_system_pods     = var.cluster_autoscaler_profile.skip_nodes_with_system_pods
      max_graceful_termination_sec    = var.cluster_autoscaler_profile.max_graceful_termination_sec
      scale_down_utilization_threshold = var.cluster_autoscaler_profile.scale_down_utilization_threshold
      new_pod_scale_up_delay          = var.cluster_autoscaler_profile.new_pod_scale_up_delay
      max_total_unready_percentage    = var.cluster_autoscaler_profile.max_total_unready_percentage
      ok_total_unready_count          = var.cluster_autoscaler_profile.ok_total_unready_count
    }
  }

  # Automatic channel upgrade
  automatic_channel_upgrade = var.aks_automatic_channel_upgrade

  tags = local.common_tags

  depends_on = [
    azurerm_container_registry.acr
  ]
}

# ==============================================================================
# Additional Node Pools
# ==============================================================================

resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  for_each = { for idx, pool in var.additional_node_pools : pool.name => pool }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.enable_auto_scaling != null && each.value.enable_auto_scaling ? null : each.value.node_count
  min_count             = each.value.enable_auto_scaling != null && each.value.enable_auto_scaling ? (each.value.min_count != null ? each.value.min_count : 1) : null
  max_count             = each.value.enable_auto_scaling != null && each.value.enable_auto_scaling ? (each.value.max_count != null ? each.value.max_count : 3) : null
  max_pods              = each.value.max_pods != null ? each.value.max_pods : 110
  node_labels           = each.value.node_labels != null ? each.value.node_labels : {}
  os_disk_size_gb       = each.value.os_disk_size_gb != null ? each.value.os_disk_size_gb : 128
  os_disk_type          = each.value.os_disk_type != null ? each.value.os_disk_type : "Managed"
  os_sku                = each.value.os_sku != null ? each.value.os_sku : "Ubuntu"
  zones                 = each.value.zones != null ? each.value.zones : []
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled != null ? each.value.ultra_ssd_enabled : false
  mode                  = each.value.mode != null ? each.value.mode : "User"
  priority              = each.value.priority != null ? each.value.priority : "Regular"
  eviction_policy       = each.value.eviction_policy != null ? each.value.eviction_policy : "Delete"
  spot_max_price        = each.value.spot_max_price

  tags = local.common_tags
}

# ==============================================================================
# AKS-ACR Integration
# ==============================================================================

# Grant AKS cluster pull permissions to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.acr_admin_enabled ? 0 : 1
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = local.use_managed_identity ? azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id : azurerm_kubernetes_cluster.aks.service_principal[0].object_id
}

# Grant AKS cluster push permissions to ACR (if needed)
resource "azurerm_role_assignment" "aks_acr_push" {
  count                = var.acr_admin_enabled ? 0 : 1
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = local.use_managed_identity ? azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id : azurerm_kubernetes_cluster.aks.service_principal[0].object_id
}

# ==============================================================================
# Kubernetes Provider Configuration
# ==============================================================================

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
  password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
    password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
} 