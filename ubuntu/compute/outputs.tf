output "vm_names" {
  value = keys(openstack_compute_instance_v2.vms)
}

output "floating_ips" {
  value = [
    for name, fip in openstack_networking_floatingip_v2.fips :
    fip.address
  ]
}

