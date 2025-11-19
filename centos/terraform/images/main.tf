resource "openstack_images_image_v2" "image" {
  for_each         = var.img
  name             = each.value.name
  local_file_path  = each.value.local_file_path
  container_format = "bare"
  disk_format      = "qcow2"


  properties = {
    min_disk_gb = 30
    min_ram_mb  = 2048
  }
}
