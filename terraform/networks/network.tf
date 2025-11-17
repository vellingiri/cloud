# Creating private openstack network
resource "openstack_networking_network_v2" "private_network" {
  name           = "private_network"
  admin_state_up = "true"
}

# Creating openstack subnet with CIDR
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "private_subnet"
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = var.subnet_cidr
  gateway_ip	  = "10.0.1.1"
  ip_version      = 4
  dns_nameservers = ["192.168.2.5"]
  depends_on      = [openstack_networking_network_v2.private_network]

}


# Creating router interface and attaching subnet to the router to make it reach the outside networks
resource "openstack_networking_router_interface_v2" "router1" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}


# Creating private openstack network
resource "openstack_networking_network_v2" "external_network" {
  name           = "external_network"
  segments {
    network_type   = "flat"
    #physical_network = "extnet" #Centos
    physical_network = "physnet1" #Ubuntu
  }
  shared         = "true"
  admin_state_up = "true"
  external       = "true"
}

# Creating openstack subnet with CIDR
resource "openstack_networking_subnet_v2" "public_subnet" {
  name            = "public_subnet"
  network_id      = openstack_networking_network_v2.external_network.id
  cidr            = "192.168.2.0/24"
  gateway_ip	  = "192.168.2.1"
  enable_dhcp 	  = "true"
  ip_version      = 4
  #dns_nameservers = ["192.168.2.5"]
  allocation_pool {
    start = "192.168.2.101"
    end   = "192.168.2.200"
  }

}

# Creating openstack router
resource "openstack_networking_router_v2" "router" {
  name                = "router"
  external_network_id = openstack_networking_network_v2.external_network.id
}
