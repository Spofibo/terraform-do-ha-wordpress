locals {
  sites = [
    {
      name     = "website1.com"
      host     = digitalocean_database_cluster.mysql.private_host
      port     = digitalocean_database_cluster.mysql.port
      username = digitalocean_database_user.website1.name
      password = digitalocean_database_user.website1.password
      db       = digitalocean_database_db.website1.name
    },
    {
      name     = "website2.com"
      host     = digitalocean_database_cluster.mysql.private_host
      port     = digitalocean_database_cluster.mysql.port
      username = digitalocean_database_user.website2.name
      password = digitalocean_database_user.website2.password
      db       = digitalocean_database_db.website2.name
    }
  ]
}

output "wordpress_lb_ip" {
  value = digitalocean_loadbalancer.wordpress.ip
}

### The Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory"
  content = templatefile("inventory.tpl", {
    sites = jsonencode(local.sites),
    servers = digitalocean_droplet.wordpress
  })
}
