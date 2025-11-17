variable "os_auth_url"       { type = string }
variable "os_username"       { type = string }
variable "os_password"       { type = string }
variable "os_project_name"   { type = string }
variable "os_region"         { type = string }
variable "os_domain_name"    { type = string }

# Environment-specific settings
variable "env_name" {
  type    = string
  default = "dev"
}

variable "external_network_name" {
  description = "Existing external network in OpenStack"
  type        = string
  default     = "external_network" # change to your real external net name
}

variable "private_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "dns_zone_name" {
  description = "Root DNS zone managed by Designate (must end with a dot)"
  type        = string
  default     = "rdulinux.com."
}

variable "dns_ttl" {
  type    = number
  default = 300
}

variable "image_name" {
  description = "Glance image name for instances"
  type        = string
  default     = "ubuntu-24.04"
}

variable "flavor_name" {
  description = "Nova flavor name"
  type        = string
  default     = "m1.small"
}

variable "ssh_key_name" {
  description = "Existing or to-be-created SSH keypair name"
  type        = string
  default     = "dev-key"
}

variable "ssh_public_key" {
  description = "Public key content used if keypair is created"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create in this env"
  type        = number
  default     = 1
}

