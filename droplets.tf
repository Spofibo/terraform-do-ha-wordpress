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

################################################################################
# Update the ansible inventory file, with ip address of wordpress servers      #
################################################################################
resource "null_resource" "wordpress_servers_ansible" {
  # Hack to update the inventory file automatically, with the change of wordpress instances
  triggers = {
    instances = join(",", digitalocean_droplet.wordpress[*].id)
  }

  depends_on = [
    digitalocean_droplet.wordpress,
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.wordpress[0].name} ansible_host=${digitalocean_droplet.wordpress[0].ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > ./ansible/inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.wordpress[1].name} ansible_host=${digitalocean_droplet.wordpress[1].ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' >> ./ansible/inventory"
  }
}