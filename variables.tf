variable "do_token" {
  type = string
}

variable "region" {
  type    = string
  default = "fra1"
}

variable "name_prefix" {
  type    = string
  default = "terraform"
}

variable "ssh_fingerprint" {
  type = string
}