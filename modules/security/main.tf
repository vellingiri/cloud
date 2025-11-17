# A basic default SG allowing all egress
resource "openstack_networking_secgroup_v2" "default" {
  name        = "${var.env_name}-default-sg"
  description = "Default security group for ${var.env_name}"
}

# Allow all egress
resource "openstack_networking_secgroup_rule_v2" "default_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default.id
}

# SSH SG
resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "${var.env_name}-ssh-sg"
  description = "Allow SSH"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh.id
}

# ICMP SG
resource "openstack_networking_secgroup_v2" "icmp" {
  name        = "${var.env_name}-icmp-sg"
  description = "Allow ICMP"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.icmp.id
}

