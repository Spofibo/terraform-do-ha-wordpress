################################################################################
# Create a VPC for isolating our traffic                                       #
################################################################################
resource "digitalocean_vpc" "this" {
  name     = "${var.name_prefix}-network"
  region   = var.region
  ip_range = "10.10.10.0/24"
}