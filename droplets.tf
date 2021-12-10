################################################################################
# Create 2 web servers with nginx and php, to serve wordpress sites            #
################################################################################
resource "digitalocean_droplet" "wordpress" {
  count    = 2
  image    = "ubuntu-21-10-x64"
  name     = "${var.name_prefix}-wordpress-${count.index}"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
  vpc_uuid = digitalocean_vpc.this.id

  tags = [var.name_prefix, "wordpress"]

  #-----------------------------------------------------------------------------------------------#
  # Ensures that we create the new resource before we destroy the old one                         #
  # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations #
  #-----------------------------------------------------------------------------------------------#
  lifecycle {
    create_before_destroy = true
  }
}