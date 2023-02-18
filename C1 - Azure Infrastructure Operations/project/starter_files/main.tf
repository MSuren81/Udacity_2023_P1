locals {
  common_tags = {
    environment  = "${var.environment}"
    project      = "${var.project}"  
  }
}

provider "azurerm" {
  features {}
}

data azurerm_subscription "current" { }

data "azurerm_image" "customimage" {
   name                = "myPackerimageUdacity"
   resource_group_name = "Udacity_RG_P1"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-ressources"
  location = var.location
  tags = "${merge(local.common_tags)}"
  
}
# Define virtual network and subnet
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = "${merge(local.common_tags)}"
}

# Define subnet
resource "azurerm_subnet" "internal" {
  name                 = "subnet-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define Network Interface NIC
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${count.index +1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  count               = 2
  tags = "${merge(local.common_tags)}"

  ip_configuration {
    name                          = "internal-${count.index +1}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define Network security group
resource "azurerm_network_security_group" "webserver" {
  name                = "NSG_Udacity_2023_P1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = "${merge(local.common_tags)}"
}

resource "azurerm_network_security_rule" "Disallow_all_extern" {
    access                     = "Deny"
    direction                  = "Inbound"
    name                       = "Disallow_all_extern"
    priority                   = 100
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_port_range     = "*"
    destination_address_prefix = "VirtualNetwork"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.webserver.name
}

resource "azurerm_network_security_rule" "allow_all_intern_in" {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "allow_intern_in"
    priority                   = 110
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_port_range     = "*"
    destination_address_prefix = "VirtualNetwork"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.webserver.name
}

resource "azurerm_network_security_rule" "allow_all_intern_out" {
    access                     = "Allow"
    direction                  = "Outbound"
    name                       = "allow_intern_out"
    priority                   = 120
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_port_range     = "*"
    destination_address_prefix = "VirtualNetwork"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.webserver.name
}

resource "azurerm_network_security_rule" "allow_LoadBalancer" {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "allow_Loadbalancer"
    priority                   = 130
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadbalancer"
    destination_port_range     = "*"
    destination_address_prefix = "VirtualNetwork"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.webserver.name
}

resource "azurerm_public_ip" "main" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  tags = "${merge(local.common_tags)}"
}

resource "azurerm_lb" "loadbalancer" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer" {
  loadbalancer_id        = azurerm_lb.loadbalancer.id
  name                   = "backendAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "loadbalancer" {
  network_interface_id    = azurerm_resource_group.main.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadbalancer.id
}

resource "azurerm_lb_nat_pool" "loadbalancer" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 443
  frontend_port_end              = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "LoadbancerNatRule" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAdress"
}

# Define availablitlty set
resource "azurerm_availability_set" "availablitltySet" {
  name                         = "availablitltySet"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Definfe vm 
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vmCount
  name                            = "${var.prefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.availablitltySet.id
  tags = "${merge(local.common_tags)}"

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

# Define custom created Image 


  source_image_id = data.azurerm_image.customimage.id
  
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}