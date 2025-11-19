resource "openstack_compute_secgroup_v2" "repo" {
  name        = "repo"
  description = "a security group by terraform"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 8140
    to_port     = 8140
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}
