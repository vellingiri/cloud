variable "kubernetes" {
  type = map(any)
  default = {
    vm1 = {
      name        = "controlplane"
      image_name  = "ubuntu2204"
      flavor_name = "m1.medium"
    }
    vm2 = {
      name        = "node1"
      image_name  = "ubuntu2204"
      flavor_name = "m1.small"
    }
    vm3 = {
      name        = "node2"
      image_name  = "ubuntu2204"
      flavor_name = "m1.small"
    }
  }
}

data "openstack_dns_zone_v2" "rdulinux_zone" {
  name = "rdulinux.com."
}

data "openstack_dns_zone_v2" "reverse_zone" {
  name = "2.168.192.in-addr.arpa."
}

variable "domain_name" {
  default = "rdulinux.com."
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "keypair" {
  default = "kubernetes"
}
