# Keypair
resource "openstack_compute_keypair_v2" "this" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

# Ports
resource "openstack_networking_port_v2" "ports" {
  count = var.vm_count

  name           = "${var.env_name}-${var.base_hostname}-${count.index}-port"
  network_id     = var.network_id
  admin_state_up = true

  security_group_ids = var.security_group_ids
}

# Floating IPs
resource "openstack_networking_floatingip_v2" "fips" {
  count = var.vm_count

  pool = var.external_network_id
}

# Attach FIP to port
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count = var.vm_count

  floating_ip = openstack_networking_floatingip_v2.fips[count.index].address
  port_id     = openstack_networking_port_v2.ports[count.index].id
}

# Servers
resource "openstack_compute_instance_v2" "servers" {
  count = var.vm_count

  name            = "${var.env_name}-${var.base_hostname}-${count.index}"
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.this.name
  security_groups = [] # using Neutron port SGs instead

  network {
    port = openstack_networking_port_v2.ports[count.index].id
  }

  # Optional: cloud-init
  # user_data = file("${path.module}/cloud-init.yaml")
}

# DNS records for each server
resource "openstack_dns_recordset_v2" "a_records" {
  count = var.vm_count

  zone_id = var.dns_zone_id
  name    = "${var.env_name}-${var.base_hostname}-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = 300

  records = [
    openstack_networking_floatingip_v2.fips[count.index].address
  ]
}

