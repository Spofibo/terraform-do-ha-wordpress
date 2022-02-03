locals {
  sites = [
    {
      name = "website"
      url  = "website1.com"
      db = {
        host     = digitalocean_database_cluster.mysql.private_host
        port     = digitalocean_database_cluster.mysql.port
        username = digitalocean_database_user.website1.name
        password = digitalocean_database_user.website1.password
        name     = digitalocean_database_db.website1.name
      }
    },
    {
      name = "website2"
      url  = "website2.com"
      db = {
        host     = digitalocean_database_cluster.mysql.private_host
        port     = digitalocean_database_cluster.mysql.port
        username = digitalocean_database_user.website2.name
        password = digitalocean_database_user.website2.password
        name     = digitalocean_database_db.website2.name
      }
    }
  ]
}

output "wordpress_lb_ip" {
  value = digitalocean_loadbalancer.wordpress.ip
}

### The Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible-wordpress/inventory"
  content = templatefile("inventory.tpl", {
    sites   = jsonencode(local.sites),
    servers = digitalocean_droplet.wordpress
  })
}
