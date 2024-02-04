# should this be in a providers.tf
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

provider "vault" {
  skip_tls_verify = true
  address         = var.vault_addr
  token           = var.vault_token
}

provider "proxmox" {
  pm_api_url      = "https://${data.vault_kv_secret_v2.proxmox.data["host"]}:8006/api2/json"
  pm_password     = data.vault_kv_secret_v2.proxmox.data["password"]
  pm_user         = "root@pam"
  pm_tls_insecure = true
  pm_debug        = true
}
