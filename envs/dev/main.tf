terraform {
  required_version = ">= 1.4.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.54.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.os_auth_url
  region      = var.os_region
  user_name   = var.os_username
  password    = var.os_password
  tenant_name = var.os_project_name
  domain_name = var.os_domain_name
}

# ─────────────────────
# Data: external network
# ─────────────────────
data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# ─────────────────────
# Network + Subnet
# ─────────────────────
module "network" {
  source = "../../modules/network"

  env_name     = var.env_name
  cidr         = var.private_cidr
  dns_servers  = ["8.8.8.8", "1.1.1.1"]
}

# ─────────────────────
# Router (connects private to external)
# ─────────────────────
module "router" {
  source = "../../modules/router"

  env_name          = var.env_name
  external_net_id   = data.openstack_networking_network_v2.external.id
  private_subnet_id = module.network.subnet_id
}

# ─────────────────────
# Security groups (SSH + ICMP)
# ─────────────────────
module "security" {
  source = "../../modules/security"

  env_name = var.env_name
}

# ─────────────────────
# DNS (Designate)
# ─────────────────────
module "dns" {
  source = "../../modules/dns"

  zone_name = var.dns_zone_name
  ttl       = var.dns_ttl
}

# ─────────────────────
# Servers
# ─────────────────────
module "servers" {
  source = "../../modules/server"

  env_name           = var.env_name
  image_name         = var.image_name
  flavor_name        = var.flavor_name
  network_id         = module.network.network_id
  subnet_id          = module.network.subnet_id
  external_network_id = data.openstack_networking_network_v2.external.id

  ssh_key_name   = var.ssh_key_name
  ssh_public_key = var.ssh_public_key

  security_group_ids = [
    module.security.ssh_sg_id,
    module.security.default_sg_id,
  ]

  vm_count      = var.vm_count
  base_hostname = "dev-vm"
  dns_zone_id   = module.dns.zone_id
}

