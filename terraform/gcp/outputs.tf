output "cluster_name" {
  value = google_container_cluster.main.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.main.endpoint
  sensitive = true
}

output "region" {
  value = var.region
}

output "project_id" {
  value = var.project_id
}
