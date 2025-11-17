variable "env_name"           { type = string }
variable "image_name"         { type = string }
variable "flavor_name"        { type = string }
variable "network_id"         { type = string }
variable "subnet_id"          { type = string }
variable "external_network_id"{ type = string }

variable "ssh_key_name"   { type = string }
variable "ssh_public_key" { type = string }

variable "security_group_ids" {
  type = list(string)
}

variable "vm_count" {
  type = number
}

variable "base_hostname" {
  type    = string
  default = "vm"
}

variable "dns_zone_id" { type = string }

variable "dns_suffix" {
  description = "Suffix without leading dot, e.g. rdulinux.com."
  type        = string
  default     = "rdulinux.com."
}

