resource "openstack_dns_zone_v2" "rdulinux_zone" {
  name  = "rdulinux.com."
  email = "openstack@rdulinux.com"
  ttl   = 6000
  type  = "PRIMARY"
}

resource "openstack_dns_zone_v2" "reverse_zone" {
  name  = "2.168.192.in-addr.arpa."
  email = "openstack@rdulinux.com"
  ttl   = 6000
  type  = "PRIMARY"
}

resource "openstack_dns_recordset_v2" "rdulinux_com" {
  zone_id = openstack_dns_zone_v2.rdulinux_zone.id
  name    = "openstack.rdulinux.com."
  ttl     = 3000
  type    = "A"
  records = ["192.168.2.3"]
}


resource "openstack_dns_recordset_v2" "reverse_zone" {
  zone_id = openstack_dns_zone_v2.reverse_zone.id
  name    = "3.2.168.192.in-addr.arpa."
  ttl     = 3000
  type    = "PTR"
  records = ["openstack.rdulinux.com."]
}

resource "openstack_dns_recordset_v2" "c3_cname" {
  zone_id = openstack_dns_zone_v2.rdulinux_zone.id
  name	  = "c3.rdulinux.com."
  ttl     = 3000
  type    = "CNAME"
  records = ["openstack.rdulinux.com."]
}
