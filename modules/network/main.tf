resource "openstack_networking_network_v2" "this" {
  name           = "${var.env_name}-private-net"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "this" {
  name            = "${var.env_name}-private-subnet"
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = var.dns_servers
}

