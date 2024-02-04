provider "vault" {
  skip_tls_verify = true
  address         = var.vault_addr
  token           = var.vault_token
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.5"
    }
  }
  # backend "http" {}
  backend "s3" {
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}
