variable "env_name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

