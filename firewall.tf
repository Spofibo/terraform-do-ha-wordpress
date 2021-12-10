resource "digitalocean_database_firewall" "mysql" {
  cluster_id = digitalocean_database_cluster.mysql.id

  rule {
    type  = "ip_addr"
    value = chomp(data.http.myip.body)
  }

  dynamic "rule" {
    for_each = digitalocean_droplet.wordpress
    content {
      type  = "droplet"
      value = rule.value.id
    }
  }
}

################################################################################
# Firewall Rules for our Webserver Droplets                                    #
################################################################################
resource "digitalocean_firewall" "wordpress" {
  name        = "minimal-vpc-only-vpc-traffic"
  droplet_ids = digitalocean_droplet.wordpress.*.id

  #--------------------------------------------------------------------------#
  # Internal VPC Rules. We have to let ourselves talk to each other          #
  #--------------------------------------------------------------------------#
  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    source_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = [digitalocean_vpc.this.ip_range, chomp(data.http.myip.body)]
  }

  #--------------------------------------------------------------------------#
  # Selective Outbound Traffic Rules                                         #
  #--------------------------------------------------------------------------#

  # DNS
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # ICMP (Ping)
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow lb healthchecks
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [digitalocean_loadbalancer.wordpress.ip]
  }
}