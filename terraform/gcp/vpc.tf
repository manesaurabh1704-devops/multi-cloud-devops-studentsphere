# ─────────────────────────────────────────
# VPC Network
# ─────────────────────────────────────────
resource "google_compute_network" "main" {
  name                    = "studentsphere-vpc"
  auto_create_subnetworks = false
}

# ─────────────────────────────────────────
# Public Subnet — Load Balancer only
# ─────────────────────────────────────────
resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

# ─────────────────────────────────────────
# Private Subnet — GKE Nodes
# ─────────────────────────────────────────
resource "google_compute_subnetwork" "private" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# ─────────────────────────────────────────
# Cloud Router — For Cloud NAT
# ─────────────────────────────────────────
resource "google_compute_router" "main" {
  name    = "studentsphere-router"
  region  = var.region
  network = google_compute_network.main.id
}

# ─────────────────────────────────────────
# Cloud NAT — Private nodes outbound internet
# ─────────────────────────────────────────
resource "google_compute_router_nat" "main" {
  name                               = "studentsphere-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
