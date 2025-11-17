#################################
# Compute Outputs
#################################
output "vm_names" {
  value = module.compute.vm_names
}

output "floating_ips" {
  value = module.compute.floating_ips
}

#################################
# DNS Records
#################################
output "dns_forward_records" {
  value = module.dns_records.forward_records
}

output "dns_reverse_records" {
  value = module.dns_records.reverse_records
}

#################################
# Network Info
#################################
output "private_network_id" {
  value = module.network.private_network_id
}

output "external_network_name" {
  value = module.network.external_network_name
}

#################################
# Keypair
#################################
output "keypair_name" {
  value = module.keypair.keypair_name
}

