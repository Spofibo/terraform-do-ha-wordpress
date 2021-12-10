terraform {
  required_version = ">= 1.0.0"

  backend "remote" {
    organization = "w0rldart"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.16"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}