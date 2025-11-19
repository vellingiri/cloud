variable "subnet_cidr" {
  type        = string
  description = "Openstack subnet CIDR where instances IPs will be assigned"
  default     = "10.0.1.0/24"

}
