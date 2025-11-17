variable "zone_name" {
  description = "DNS zone name (must end with a dot)"
  type        = string
}

variable "admin_email" {
  description = "SOA email"
  type        = string
  default     = "admin.rdulinux.com."
}

variable "ttl" {
  type    = number
  default = 300
}

