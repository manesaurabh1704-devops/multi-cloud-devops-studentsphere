variable "subscription_id" {
  description = "Azure Subscription ID"
  default     = "e4406eac-61e8-4937-9299-66fe1a0f88e8"
}

variable "location" {
  description = "Azure region"
  default     = "West US 2"
}

variable "resource_group_name" {
  description = "Resource group name"
  default     = "studentsphere-rg"
}

variable "cluster_name" {
  description = "AKS cluster name"
  default     = "studentsphere-aks"
}

variable "node_count" {
  description = "Number of nodes"
  default     = 2
}

variable "node_size" {
  description = "Node VM size"
  default     = "Standard_B2s_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  default     = "1.35.1"
}
