variable "project_id" {
  description = "GCP Project ID"
  default     = "project-a3e71bc3-7f01-47c1-ae7"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "GKE cluster name"
  default     = "studentsphere-gke"
}

variable "node_count" {
  description = "Number of nodes"
  default     = 2
}

variable "node_machine_type" {
  description = "Node machine type"
  default     = "e2-medium"
}
