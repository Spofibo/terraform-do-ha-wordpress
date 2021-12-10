resource "digitalocean_database_cluster" "mysql" {
  name       = "${var.name_prefix}-mysql-cluster"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  private_network_uuid = digitalocean_vpc.this.id
}

resource "digitalocean_database_db" "website1" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "website1"
}

resource "digitalocean_database_user" "website1" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "website1_user"
}

resource "digitalocean_database_db" "website2" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "website2"
}

resource "digitalocean_database_user" "website2" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "website2_user"
}