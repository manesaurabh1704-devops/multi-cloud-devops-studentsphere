# ─────────────────────────────────────────
# Resource Group
# ─────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ─────────────────────────────────────────
# Virtual Network
# ─────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = "studentsphere-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  depends_on = [azurerm_resource_group.main]
}

# ─────────────────────────────────────────
# Public Subnet — Load Balancer only
# ─────────────────────────────────────────
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.main]
}

# ─────────────────────────────────────────
# Private Subnet — AKS Nodes
# ─────────────────────────────────────────
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.main]
}

# ─────────────────────────────────────────
# Public IP for NAT Gateway
# ─────────────────────────────────────────
resource "azurerm_public_ip" "nat" {
  name                = "studentsphere-nat-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_resource_group.main]
}

# ─────────────────────────────────────────
# NAT Gateway
# ─────────────────────────────────────────
resource "azurerm_nat_gateway" "main" {
  name                = "studentsphere-nat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"

  depends_on = [azurerm_resource_group.main]
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id

  depends_on = [
    azurerm_nat_gateway.main,
    azurerm_public_ip.nat
  ]
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.main.id

  depends_on = [
    azurerm_subnet.private,
    azurerm_nat_gateway_public_ip_association.main
  ]
}
