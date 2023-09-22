### Terraform provider to get Terraform plugin's to Local machine
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.39.1"
    }
  }
}

### Authenticate Terraform to Azure using Service Principal
provider "azurerm" {
  features {}
  subscription_id = "xxxxx"
  client_id       = "xxxxx"
  tenant_id       = "xxxxx"
  client_secret   = "xxxxx"
}


### Creat a Resource Group in HUB
resource "azurerm_resource_group" "rg-hub" {
  name     = "RG-${var.client}-${var.department}-${var.env}-AE-HUB" # Naming Standard: <resoureName>-<clientName>-<domainName>-<environmentame>-<location>-<ordinal>
  location = var.target_region
}

### Creat a Resource Group in dev
resource "azurerm_resource_group" "rg-dev" {
  name     = "RG-${var.client}-${var.department}-${var.env}-AE-DEV" # Naming Standard: <resoureName>-<clientName>-<domainName>-<environmentame>-<location>-<ordinal>
  location = var.target_region
}

### Creat a Resource Group in qa
resource "azurerm_resource_group" "rg-qa" {
  name     = "RG-${var.client}-${var.department}-${var.env}-AE-QA" # Naming Standard: <resoureName>-<clientName>-<domainName>-<environmentame>-<location>-<ordinal>
  location = var.target_region
}

### Creat a Resource Group in prod
resource "azurerm_resource_group" "rg-prod" {
  name     = "RG-${var.client}-${var.department}-${var.env}-AE-PROD" # Naming Standard: <resoureName>-<clientName>-<domainName>-<environmentame>-<location>-<ordinal>
  location = var.target_region
}


### Create a Vnet in HUB
resource "azurerm_virtual_network" "vnet-hub" {
  name                = "VNET-${var.client}-${var.department}-${var.env}-AE-HUB"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg-hub.location
  resource_group_name = azurerm_resource_group.rg-hub.name
}

### Create a Vnet in DEV
resource "azurerm_virtual_network" "vnet-dev" {
  name                = "VNET-${var.client}-${var.department}-${var.env}-AE-DEV"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.rg-dev.location
  resource_group_name = azurerm_resource_group.rg-dev.name
}

### Create a Vnet in QA
resource "azurerm_virtual_network" "vnet-qa" {
  name                = "VNET-${var.client}-${var.department}-${var.env}-AE-QA"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.rg-qa.location
  resource_group_name = azurerm_resource_group.rg-qa.name
}

### Create a Vnet in PROD
resource "azurerm_virtual_network" "vnet-prod" {
  name                = "VNET-${var.client}-${var.department}-${var.env}-AE-PROD"
  address_space       = ["10.40.0.0/16"]
  location            = azurerm_resource_group.rg-prod.location
  resource_group_name = azurerm_resource_group.rg-prod.name
}

### Create a Subnet
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "SUB-${var.client}-${var.department}-${var.env}-AE-01"
  address_prefixes     = ["10.10.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg-hub.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
}

### Creat a Public IP for VPN Gateway
resource "azurerm_public_ip" "pip" {
  name                = "pip01"
  resource_group_name = azurerm_resource_group.rg-hub.name
  location            = azurerm_resource_group.rg-hub.location
  allocation_method   = "Static"

  depends_on = [
    azurerm_virtual_network.vnet-hub,
    azurerm_subnet.GatewaySubnet
  ]
}


### Create a Virtual Network Gateway in Hub Network
resource "azurerm_virtual_network_gateway" "vng-hub" {
  name                = "VPG-${var.client}-${var.department}-${var.env}-AE-01"
  location            = var.target_region
  resource_group_name = azurerm_resource_group.rg-hub.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = "false"
  enable_bgp    = "false"
  sku           = "Basic"

  ip_configuration {
    name                          = "VnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
  }

  vpn_client_configuration {
    address_space = ["192.168.1.0/24"]

    root_certificate {
      name = "Root-CA"

      public_cert_data = <<EOF

EOF

    }

  }
}


### Peering between Hub and Dev
resource "azurerm_virtual_network_peering" "hub_dev" {
  name                         = "hub_dev"
  resource_group_name          = azurerm_resource_group.rg-hub.name
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-dev.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}

### Peering between Dev and Hub
resource "azurerm_virtual_network_peering" "dev_hub" {
  name                         = "dev_hub"
  resource_group_name          = azurerm_resource_group.rg-dev.name
  virtual_network_name         = azurerm_virtual_network.vnet-dev.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

### Peering between Hub and QA
resource "azurerm_virtual_network_peering" "hub_qa" {
  name                         = "hub_qa"
  resource_group_name          = azurerm_resource_group.rg-hub.name
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-qa.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}

### Peering between QA and Hub
resource "azurerm_virtual_network_peering" "qa_hub" {
  name                         = "qa_hub"
  resource_group_name          = azurerm_resource_group.rg-qa.name
  virtual_network_name         = azurerm_virtual_network.vnet-qa.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

### Peering between Hub and PROD
resource "azurerm_virtual_network_peering" "hub_prod" {
  name                         = "hub_prod"
  resource_group_name          = azurerm_resource_group.rg-hub.name
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-prod.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}

### Peering between PROD and Hub
resource "azurerm_virtual_network_peering" "prod_hub" {
  name                         = "prod_hub"
  resource_group_name          = azurerm_resource_group.rg-prod.name
  virtual_network_name         = azurerm_virtual_network.vnet-prod.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
} 


### Create a NIC
resource "azurerm_network_interface" "my-nic" {
  name                = "mynic"
  location            = azurerm_resource_group.rg-hub.location
  resource_group_name = azurerm_resource_group.rg-hub.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${azurerm_subnet.GatewaySubnet.id}"
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.pip.id

  }
} 


resource "azurerm_linux_virtual_machine" "vm-dev" {
  name                = "VPG-${var.client}-${var.department}-${var.env}-AE-01"
  resource_group_name = azurerm_resource_group.rg-dev
  location            = var.target_region
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.my-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
