# ─────────────────────────────────────────
# GKE Cluster
# ─────────────────────────────────────────
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.private.name

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  deletion_protection = false
}

# ─────────────────────────────────────────
# GKE Node Pool
# ─────────────────────────────────────────
resource "google_container_node_pool" "main" {
  name       = "studentsphere-nodes"
  location   = var.zone
  cluster    = google_container_cluster.main.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      Environment = "phase10"
      Project     = "studentsphere"
    }
  }
}
