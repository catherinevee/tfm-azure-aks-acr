# ==============================================================================
# General Variables
# ==============================================================================

variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
  default     = "aks-acr"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Azure Container Registry (ACR) Variables
# ==============================================================================

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Enable public network access for ACR"
  type        = bool
  default     = true
}

variable "acr_network_rule_set" {
  description = "Network rule set for ACR"
  type = list(object({
    subnet_id                    = string
    action                       = string
    virtual_network_subnet_id    = string
  }))
  default = []
}

variable "acr_retention_policy" {
  description = "Retention policy for ACR"
  type = object({
    days    = number
    enabled = bool
  })
  default = {
    days    = 7
    enabled = true
  }
}

variable "acr_trust_policy" {
  description = "Trust policy for ACR"
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "acr_encryption" {
  description = "Encryption settings for ACR"
  type = object({
    enabled = bool
    key_vault_key_id = optional(string)
    identity_client_id = optional(string)
  })
  default = {
    enabled = false
  }
}

# ==============================================================================
# Azure Kubernetes Service (AKS) Variables
# ==============================================================================

variable "aks_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.28.0"
}

variable "aks_sku_tier" {
  description = "SKU tier for AKS cluster"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Paid"], var.aks_sku_tier)
    error_message = "AKS SKU tier must be either Free or Paid."
  }
}

variable "aks_automatic_channel_upgrade" {
  description = "Automatic channel upgrade for AKS cluster"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["rapid", "stable", "patch", "node-image", "none"], var.aks_automatic_channel_upgrade)
    error_message = "Automatic channel upgrade must be one of: rapid, stable, patch, node-image, none."
  }
}

variable "aks_network_plugin" {
  description = "Network plugin for AKS cluster"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "kubenet"], var.aks_network_plugin)
    error_message = "Network plugin must be either azure or kubenet."
  }
}

variable "aks_network_policy" {
  description = "Network policy for AKS cluster"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "calico"], var.aks_network_policy)
    error_message = "Network policy must be either azure or calico."
  }
}

variable "aks_pod_cidr" {
  description = "Pod CIDR for AKS cluster"
  type        = string
  default     = "10.244.0.0/16"
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS cluster"
  type        = string
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "Docker bridge CIDR for AKS cluster"
  type        = string
  default     = "172.17.0.1/16"
}

variable "aks_outbound_type" {
  description = "Outbound type for AKS cluster"
  type        = string
  default     = "loadBalancer"
  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting"], var.aks_outbound_type)
    error_message = "Outbound type must be either loadBalancer or userDefinedRouting."
  }
}

variable "aks_load_balancer_sku" {
  description = "Load balancer SKU for AKS cluster"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["basic", "standard"], var.aks_load_balancer_sku)
    error_message = "Load balancer SKU must be either basic or standard."
  }
}

variable "aks_http_application_routing_enabled" {
  description = "Enable HTTP application routing for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_azure_policy_enabled" {
  description = "Enable Azure Policy for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_open_service_mesh_enabled" {
  description = "Enable Open Service Mesh for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_key_vault_secrets_provider_enabled" {
  description = "Enable Key Vault Secrets Provider for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_workload_identity_enabled" {
  description = "Enable Workload Identity for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_oidc_issuer_enabled" {
  description = "Enable OIDC issuer for AKS cluster"
  type        = bool
  default     = false
}

variable "aks_private_cluster_enabled" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = false
}

variable "aks_private_dns_zone_id" {
  description = "Private DNS zone ID for AKS cluster"
  type        = string
  default     = null
}

variable "aks_api_server_authorized_ip_ranges" {
  description = "Authorized IP ranges for AKS API server"
  type        = list(string)
  default     = []
}

variable "aks_disk_encryption_set_id" {
  description = "Disk encryption set ID for AKS cluster"
  type        = string
  default     = null
}

variable "aks_identity_type" {
  description = "Identity type for AKS cluster"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.aks_identity_type)
    error_message = "Identity type must be either SystemAssigned or UserAssigned."
  }
}

variable "aks_user_assigned_identity_id" {
  description = "User assigned identity ID for AKS cluster"
  type        = string
  default     = null
}

# ==============================================================================
# Default Node Pool Variables
# ==============================================================================

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_node_count" {
  description = "Number of nodes in default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_min_count" {
  description = "Minimum number of nodes in default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "Maximum number of nodes in default node pool"
  type        = number
  default     = 3
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable auto scaling for default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "Enable host encryption for default node pool"
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "Enable node public IP for default node pool"
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "Maximum number of pods per node in default node pool"
  type        = number
  default     = 110
}

variable "default_node_pool_node_taints" {
  description = "Node taints for default node pool"
  type        = list(string)
  default     = []
}

variable "default_node_pool_node_labels" {
  description = "Node labels for default node pool"
  type        = map(string)
  default     = {}
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size in GB for default node pool"
  type        = number
  default     = 128
}

variable "default_node_pool_os_disk_type" {
  description = "OS disk type for default node pool"
  type        = string
  default     = "Managed"
  validation {
    condition     = contains(["Managed", "Ephemeral"], var.default_node_pool_os_disk_type)
    error_message = "OS disk type must be either Managed or Ephemeral."
  }
}

variable "default_node_pool_os_sku" {
  description = "OS SKU for default node pool"
  type        = string
  default     = "Ubuntu"
  validation {
    condition     = contains(["Ubuntu", "CBLMariner", "Windows2019", "Windows2022"], var.default_node_pool_os_sku)
    error_message = "OS SKU must be one of: Ubuntu, CBLMariner, Windows2019, Windows2022."
  }
}

variable "default_node_pool_subnet_id" {
  description = "Subnet ID for default node pool"
  type        = string
  default     = null
}

variable "default_node_pool_zones" {
  description = "Availability zones for default node pool"
  type        = list(string)
  default     = []
}

variable "default_node_pool_ultra_ssd_enabled" {
  description = "Enable Ultra SSD for default node pool"
  type        = bool
  default     = false
}

variable "default_node_pool_scale_down_mode" {
  description = "Scale down mode for default node pool"
  type        = string
  default     = "Delete"
  validation {
    condition     = contains(["Delete", "Deallocate"], var.default_node_pool_scale_down_mode)
    error_message = "Scale down mode must be either Delete or Deallocate."
  }
}

# ==============================================================================
# Additional Node Pools Variables
# ==============================================================================

variable "additional_node_pools" {
  description = "Additional node pools configuration"
  type = list(object({
    name                    = string
    vm_size                 = string
    node_count              = number
    min_count              = optional(number)
    max_count              = optional(number)
    enable_auto_scaling    = optional(bool, true)
    enable_host_encryption = optional(bool, false)
    enable_node_public_ip  = optional(bool, false)
    max_pods               = optional(number, 110)
    node_taints            = optional(list(string), [])
    node_labels            = optional(map(string), {})
    os_disk_size_gb        = optional(number, 128)
    os_disk_type           = optional(string, "Managed")
    os_sku                 = optional(string, "Ubuntu")
    subnet_id              = optional(string)
    zones                  = optional(list(string), [])
    ultra_ssd_enabled      = optional(bool, false)
    scale_down_mode        = optional(string, "Delete")
    mode                   = optional(string, "User")
    priority               = optional(string, "Regular")
    eviction_policy        = optional(string, "Delete")
    spot_max_price         = optional(number)
  }))
  default = []
}

# ==============================================================================
# Monitoring and Logging Variables
# ==============================================================================

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for AKS monitoring"
  type        = string
  default     = null
}

variable "enable_oms_agent" {
  description = "Enable OMS agent for AKS cluster"
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS cluster"
  type        = bool
  default     = false
}

variable "enable_azure_key_vault_secrets_provider" {
  description = "Enable Azure Key Vault Secrets Provider for AKS cluster"
  type        = bool
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_enabled" {
  description = "Enable secret rotation for Key Vault Secrets Provider"
  type        = bool
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_interval" {
  description = "Secret rotation interval for Key Vault Secrets Provider"
  type        = string
  default     = "2m"
}

# ==============================================================================
# RBAC and Security Variables
# ==============================================================================

variable "rbac_enabled" {
  description = "Enable RBAC for AKS cluster"
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Disable local accounts for AKS cluster"
  type        = bool
  default     = false
}

variable "azure_active_directory_role_based_access_control" {
  description = "Azure AD RBAC configuration for AKS cluster"
  type = object({
    managed                = bool
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool, false)
  })
  default = {
    managed = false
  }
}

variable "service_principal" {
  description = "Service principal configuration for AKS cluster"
  type = object({
    client_id     = string
    client_secret = string
  })
  default = null
  sensitive = true
}

# ==============================================================================
# Maintenance Window Variables
# ==============================================================================

variable "maintenance_window" {
  description = "Maintenance window configuration for AKS cluster"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default = null
}

# ==============================================================================
# Auto Scaler Profile Variables
# ==============================================================================

variable "cluster_autoscaler_profile" {
  description = "Cluster autoscaler profile configuration"
  type = object({
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded             = optional(string, "10m")
    scale_down_unready              = optional(string, "20m")
    max_node_provision_time         = optional(string, "15m")
    balance_similar_node_groups     = optional(bool, false)
    expander                        = optional(string, "random")
    skip_nodes_with_local_storage   = optional(bool, true)
    skip_nodes_with_system_pods     = optional(bool, true)
    max_graceful_termination_sec    = optional(string, "600")
    scale_down_utilization_threshold = optional(string, "0.5")
    new_pod_scale_up_delay          = optional(string, "10s")
    max_total_unready_percentage    = optional(string, "45")
    ok_total_unready_count          = optional(string, "3")
  })
  default = {}
} 