resource "openstack_compute_keypair_v2" "artifactory" {
  name       = "artifactory"
  public_key = file("${var.ssh_key_file}.pub")
}

resource "openstack_compute_instance_v2" "instance" {
  for_each        = var.vm
  name            = each.value.name
  image_name      = each.value.image_name
  flavor_name     = each.value.flavor_name
  key_pair        = "artifactory"
  security_groups = ["${openstack_compute_secgroup_v2.artifactory.name}"]

  network {
    name = "private_network"
  }
  user_data  = file("setup.sh")
  depends_on = [data.openstack_dns_zone_v2.rdulinux_zone, data.openstack_dns_zone_v2.reverse_zone]
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool     = "external_network"
  for_each = var.vm
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  for_each    = var.vm
  floating_ip = openstack_networking_floatingip_v2.fip_1[each.key].address
  instance_id = openstack_compute_instance_v2.instance[each.key].id
}


resource "openstack_dns_recordset_v2" "rdulinux_com" {
  for_each = var.vm
  zone_id  = data.openstack_dns_zone_v2.rdulinux_zone.id
  name     = format("%s.%s", each.value.name, var.domain_name)
  ttl      = 3000
  type     = "A"
  records  = [openstack_compute_floatingip_associate_v2.fip_1[each.key].floating_ip]
}


resource "openstack_dns_recordset_v2" "reverse_zone" {
  for_each = var.vm
  zone_id  = data.openstack_dns_zone_v2.reverse_zone.id
  name     = format("%s.%s", substr(openstack_compute_floatingip_associate_v2.fip_1[each.key].floating_ip, 10, 3), data.openstack_dns_zone_v2.reverse_zone.name)
  ttl      = 3000
  type     = "PTR"
  records  = [openstack_dns_recordset_v2.rdulinux_com[each.key].name]
}
