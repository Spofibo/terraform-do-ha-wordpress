terraform {
  required_version = ">= 1.0.0"

  ################################################################################
  # Option for Terraform Cloud backend, but you'll need to configure its         #
  # execution to run locally in order to work with tfvars                        #
  ################################################################################
  # backend "remote" {
  #   organization = "w0rldart"

  #   workspaces {
  #     name = "github"
  #   }
  # }

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
