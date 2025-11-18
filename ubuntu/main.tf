module "dns" {
  source = "./dns"
}

module "image" {
  source = "./image"
}

module "network" {
  source = "./network"
}

module "security" {
  source = "./security"
}

module "keypair" {
  source = "./keypair"
}

module "compute" {
  source = "./compute"

  vm_names     = var.vm_names
  flavor_name  = var.flavor_name
  image_name   = var.image_name
  keypair_name = var.keypair_name

  private_network_id = module.network.private_network_id
  private_subnet_id  = module.network.private_subnet_id

  # Floating IP pool is the NAME of the external network
  public_network_name = module.network.external_network_name
}

module "dns_records" {
  source = "./dns_records"

  forward_zone_id   = module.dns.forward_zone_id
  reverse_zone_id   = module.dns.reverse_zone_id
  reverse_zone_name = var.reverse_zone_name

  vm_names     = module.compute.vm_names
  floating_ips = module.compute.floating_ips

  domain = var.domain
}
