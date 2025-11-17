output "server_names" {
  value = [for s in openstack_compute_instance_v2.servers : s.name]
}

output "server_fixed_ips" {
  value = [
    for p in openstack_networking_port_v2.ports :
    p.fixed_ip[0].ip_address
  ]
}

output "server_floating_ips" {
  value = [for f in openstack_networking_floatingip_v2.fips : f.address]
}

