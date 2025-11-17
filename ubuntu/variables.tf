variable "vm_names" {
  description = "List of VM names to create"
  type        = list(string)

  default = [
    "master",
    "worker1",
    #"worker2",
    #"worker3",
    #"worker4"
  ]
}

variable "reverse_zone_name" {
  type    = string
  default = "2.168.192.in-addr.arpa."
}

variable "domain" {
  type    = string
  default = "rdulinux.com."
}

variable "flavor_name" {
  description = "OpenStack flavor name for all VMs"
  type        = string
  default     = "m1.small"
}

variable "image_name" {
  description = "OpenStack image name to use for all VMs"
  type        = string
  default     = "ubuntu2204"
}

