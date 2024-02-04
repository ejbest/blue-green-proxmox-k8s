terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.5"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
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
