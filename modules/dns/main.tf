resource "openstack_dns_zone_v2" "zone" {
  name        = var.zone_name
  email       = var.admin_email
  ttl         = var.ttl
  type        = "PRIMARY"
  description = "Managed by Terraform"
}

