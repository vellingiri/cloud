resource "openstack_compute_keypair_v2" "database" {
  name       = "database"
  public_key = file("${var.ssh_key_file}.pub")
}

resource "openstack_compute_instance_v2" "database" {
  for_each        = var.database
  name            = each.value.name
  image_name      = each.value.image_name
  flavor_name     = each.value.flavor_name
  key_pair        = "database"
  security_groups = ["${openstack_compute_secgroup_v2.database.name}"]

  network {
    name = "private_network"
  }
  user_data  = file("setup.sh")
  depends_on = [data.openstack_dns_zone_v2.rdulinux_zone, data.openstack_dns_zone_v2.reverse_zone]
}

resource "openstack_networking_floatingip_v2" "database" {
  pool     = "external_network"
  for_each = var.database
}

resource "openstack_compute_floatingip_associate_v2" "database" {
  for_each    = var.database
  floating_ip = openstack_networking_floatingip_v2.database[each.key].address
  instance_id = openstack_compute_instance_v2.database[each.key].id
}


resource "openstack_dns_recordset_v2" "database" {
  for_each = var.database
  zone_id  = data.openstack_dns_zone_v2.rdulinux_zone.id
  name     = format("%s.%s", each.value.name, var.domain_name)
  ttl      = 3000
  type     = "A"
  records  = [openstack_compute_floatingip_associate_v2.database[each.key].floating_ip]
}


resource "openstack_dns_recordset_v2" "databasereverse" {
  for_each = var.database
  zone_id  = data.openstack_dns_zone_v2.reverse_zone.id
  name     = format("%s.%s", substr(openstack_compute_floatingip_associate_v2.database[each.key].floating_ip, 10, 3), data.openstack_dns_zone_v2.reverse_zone.name)
  ttl      = 3000
  type     = "PTR"
  records  = [openstack_dns_recordset_v2.database[each.key].name]
}
