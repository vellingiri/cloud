resource "openstack_networking_port_v2" "ports" {
  for_each = toset(var.vm_names)

  name       = "${each.value}-port"
  network_id = var.private_network_id
}

resource "openstack_compute_instance_v2" "vms" {
  for_each = toset(var.vm_names)

  name         = each.value
  image_name   = var.image_name
  flavor_name  = var.flavor_name
  key_pair     = var.keypair_name

  network {
    port = openstack_networking_port_v2.ports[each.key].id
  }
}

resource "openstack_networking_floatingip_v2" "fips" {
  for_each = toset(var.vm_names)

  pool = "external_network"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  for_each = toset(var.vm_names)

  floating_ip = openstack_networking_floatingip_v2.fips[each.key].address
  instance_id = openstack_compute_instance_v2.vms[each.key].id
}

