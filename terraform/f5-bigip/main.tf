terraform {
  required_providers {
    bigip = {
      source  = "F5Networks/bigip"
      version = "~> 1.24.2"
    }
  }
  required_version = ">= 1.0"
}

provider "bigip" {
  address  = var.bigip_host
  username = var.bigip_username
  password = var.bigip_password
}
