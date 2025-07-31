# ==============================================================================
# Advanced Example Variables
# ==============================================================================

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "aks-acr-advanced"
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.28.0"
}

variable "aks_sku_tier" {
  description = "SKU tier for AKS cluster"
  type        = string
  default     = "Paid"
  validation {
    condition     = contains(["Free", "Paid"], var.aks_sku_tier)
    error_message = "AKS SKU tier must be either Free or Paid."
  }
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

variable "default_node_pool_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "default_node_pool_node_count" {
  description = "Number of nodes in default node pool"
  type        = number
  default     = 2
  validation {
    condition     = var.default_node_pool_node_count >= 1
    error_message = "Default node pool must have at least 1 node."
  }
}

variable "default_node_pool_min_count" {
  description = "Minimum number of nodes in default node pool"
  type        = number
  default     = 2
  validation {
    condition     = var.default_node_pool_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "default_node_pool_max_count" {
  description = "Maximum number of nodes in default node pool"
  type        = number
  default     = 4
  validation {
    condition     = var.default_node_pool_max_count >= var.default_node_pool_min_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "user_node_pool_vm_size" {
  description = "VM size for user node pool"
  type        = string
  default     = "Standard_DS4_v2"
}

variable "user_node_pool_node_count" {
  description = "Number of nodes in user node pool"
  type        = number
  default     = 3
  validation {
    condition     = var.user_node_pool_node_count >= 1
    error_message = "User node pool must have at least 1 node."
  }
}

variable "user_node_pool_min_count" {
  description = "Minimum number of nodes in user node pool"
  type        = number
  default     = 2
  validation {
    condition     = var.user_node_pool_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "user_node_pool_max_count" {
  description = "Maximum number of nodes in user node pool"
  type        = number
  default     = 6
  validation {
    condition     = var.user_node_pool_max_count >= var.user_node_pool_min_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "spot_node_pool_vm_size" {
  description = "VM size for spot node pool"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "spot_node_pool_node_count" {
  description = "Number of nodes in spot node pool"
  type        = number
  default     = 2
  validation {
    condition     = var.spot_node_pool_node_count >= 1
    error_message = "Spot node pool must have at least 1 node."
  }
}

variable "spot_node_pool_min_count" {
  description = "Minimum number of nodes in spot node pool"
  type        = number
  default     = 1
  validation {
    condition     = var.spot_node_pool_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "spot_node_pool_max_count" {
  description = "Maximum number of nodes in spot node pool"
  type        = number
  default     = 4
  validation {
    condition     = var.spot_node_pool_max_count >= var.spot_node_pool_min_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "spot_max_price" {
  description = "Maximum price for spot instances (0.5 = 50% of regular price)"
  type        = number
  default     = 0.5
  validation {
    condition     = var.spot_max_price > 0 && var.spot_max_price <= 1
    error_message = "Spot max price must be between 0 and 1."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "acr_subnet_address_prefix" {
  description = "Address prefix for ACR subnet"
  type        = string
  default     = "10.0.2.0/24"
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

variable "api_server_authorized_ip_ranges" {
  description = "Authorized IP ranges for AKS API server"
  type        = list(string)
  default     = ["10.0.0.0/8", "192.168.0.0/16"]
}

variable "azure_ad_admin_group_name" {
  description = "Name of the Azure AD group for AKS administrators"
  type        = string
  default     = "AKS-Admins"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "maintenance_window_day" {
  description = "Day of the week for maintenance window"
  type        = string
  default     = "Sunday"
  validation {
    condition     = contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], var.maintenance_window_day)
    error_message = "Maintenance window day must be a valid day of the week."
  }
}

variable "maintenance_window_hours" {
  description = "Hours for maintenance window (0-23)"
  type        = list(number)
  default     = [0, 1, 2, 3, 4, 5, 6]
  validation {
    condition = alltrue([
      for hour in var.maintenance_window_hours : hour >= 0 && hour <= 23
    ])
    error_message = "Maintenance window hours must be between 0 and 23."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    CostCenter = "IT-001"
    Owner      = "Platform Team"
    Purpose    = "enterprise-demonstration"
  }
} 