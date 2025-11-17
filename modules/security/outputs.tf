output "default_sg_id" {
  value = openstack_networking_secgroup_v2.default.id
}

output "ssh_sg_id" {
  value = openstack_networking_secgroup_v2.ssh.id
}

output "icmp_sg_id" {
  value = openstack_networking_secgroup_v2.icmp.id
}

