resource "openstack_networking_router_v2" "this" {
  name           = "${var.env_name}-router"
  admin_state_up = true

  external_network_id = var.external_net_id
}

resource "openstack_networking_router_interface_v2" "this" {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = var.private_subnet_id
}

