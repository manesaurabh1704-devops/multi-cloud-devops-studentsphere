output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_endpoint" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive = true
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}
