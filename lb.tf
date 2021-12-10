################################################################################
# Load Balancer for distributing traffic amongst our web servers. Uses SSL     #
# termination and forwards HTTPS traffic to HTTP internally                    #
################################################################################
resource "digitalocean_loadbalancer" "wordpress" {
  name        = "${var.name_prefix}-wordpress-droplets"
  region      = var.region
  vpc_uuid    = digitalocean_vpc.this.id
  droplet_ids = concat(digitalocean_droplet.wordpress.*.id)

  #--------------------------------------------------------------------------#
  # Our servers will listen only on 443 port                                 #
  #--------------------------------------------------------------------------#
  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 443
    target_protocol = "https"

    tls_passthrough = true
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  #-----------------------------------------------------------------------------------------------#
  # Ensures that we create the new resource before we destroy the old one                         #
  # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations #
  #-----------------------------------------------------------------------------------------------#
  lifecycle {
    create_before_destroy = true
  }
}