variable "vm_names" {
  description = "List of VM names"
  type        = list(string)
}

variable "flavor_name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "private_network_id" {
  type = string
}

variable "public_network_name" {
  type = string
}

