#############################################
# ROOT VARIABLE DEFINITIONS
#############################################

variable "vm_names" {
  description = "Map of VM names to create"
  type        = map(string)
}

variable "flavor_name" {
  type    = string
  default = "m1.medium"
}

variable "image_name" {
  type    = string
  default = "ubuntu2204"
}

variable "keypair_name" {
  type    = string
  default = "default-key"
}

variable "domain" {
  default = "rdulinux.com."
}

variable "reverse_zone_name" {
  type    = string
  default = "2.168.192.in-addr.arpa."
}

