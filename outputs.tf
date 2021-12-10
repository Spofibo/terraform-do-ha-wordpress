locals {
  sites = {
    website1 = {
      host     = digitalocean_database_cluster.mysql.private_host
      port     = digitalocean_database_cluster.mysql.port
      username = digitalocean_database_user.website1.name
      password = digitalocean_database_user.website1.password
      db       = digitalocean_database_db.website1.name
    },
    website2 = {
      host     = digitalocean_database_cluster.mysql.private_host
      port     = digitalocean_database_cluster.mysql.port
      username = digitalocean_database_user.website2.name
      password = digitalocean_database_user.website2.password
      db       = digitalocean_database_db.website2.name
    }
  }
}

output "db_host" {
  value = digitalocean_database_cluster.mysql.host
}

output "sites" {
  value     = local.sites
  sensitive = true
}

output "wordpress_lb_ip" {
  value = digitalocean_loadbalancer.wordpress.ip
}