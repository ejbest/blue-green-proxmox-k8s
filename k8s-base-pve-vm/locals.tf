locals {
  env = {
    k8s-base-pve-vm-blue = {
      vault_environment = "proxmox-blue"
    }

    k8s-base-pve-vm-blue-worker = {
      vault_environment = "proxmox-blue-worker"
    }

    k8s-base-pve-vm-green = {
      vault_environment = "proxmox-green"
    }

    k8s-base-pve-vm-green-worker = {
      vault_environment = "proxmox-green-worker"
    }
  }

  workspace = local.env[terraform.workspace]
}
