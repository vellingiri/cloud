packer {
  required_plugins {
    openstack = {
      source  = "github.com/hashicorp/openstack"
      version = ">= 1.1.0"
    }
  }
}

###############################################
# VARIABLES
###############################################
variable "openstack_username" {}
variable "openstack_password" { sensitive = true }
variable "openstack_project"  {}
variable "openstack_domain"   { default = "Default" }
variable "openstack_auth_url" {}
variable "openstack_region"   { default = "RegionOne" }

variable "openstack_floating_ip_pool" {}

variable "source_image" {}
variable "flavor"       {}
variable "image_name"   {}

variable "openstack_network_id" {
  type = string
}

###############################################
# OPENSTACK BUILDER (MANDATORY image_name HERE)
###############################################
source "openstack" "ubuntu" {

  # Required params
  identity_endpoint = var.openstack_auth_url
  username          = var.openstack_username
  password          = var.openstack_password
  domain_name       = var.openstack_domain
  #project_name      = var.openstack_project
  region            = var.openstack_region

  # Image attributes
  source_image_name = var.source_image
  flavor            = var.flavor

  # REQUIRED → this creates the OpenStack image name
  image_name = var.image_name

  networks = [var.openstack_network_id]

  ssh_username    = "ubuntu"
  use_floating_ip = true
  floating_ip_pool = var.openstack_floating_ip_pool
}

###############################################
# BUILD (NO IMAGE NAME HERE)
###############################################
build {
  name    = "build-${var.image_name}"
  sources = ["source.openstack.ubuntu"]

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/install.sh",
      "${path.root}/scripts/cleanup.sh"
    ]
  }

  post-processor "manifest" {}
}

