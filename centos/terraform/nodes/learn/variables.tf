variable "learn" {
  type = map(any)
  default = {
    vm1 = {
      name        = "learn"
      image_name  = "centos8"
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
  default = "learn"
}
