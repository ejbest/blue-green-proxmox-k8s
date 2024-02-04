/* locals {
  blue         = var.deploy_env == "blue" ? "proxmox-blue" : ""
  blue_worker  = var.deploy_env == "blue_worker" ? "proxmox-blue-worker" : ""
  green        = var.deploy_env == "green" ? "proxmox-green" : ""
  green_worker = var.deploy_env == "green_worker" ? "proxmox-green-worker" : ""
  noenv        = var.deploy_env != "blue" && var.deploy_env != "blue_worker" && var.deploy_env != "green" && var.deploy_env != "green_worker" ? "null" : ""
  vault_key    = coalesce(local.blue, local.blue_worker, local.green, local.green_worker, local.noenv)
}

data "vault_kv_secret_v2" "proxmox" {
  mount = "jenkins"
  name  = local.vault_key
} */

data "vault_kv_secret_v2" "proxmox" {
  mount = "jenkins"
  name  = local.workspace["vault_environment"]
}
