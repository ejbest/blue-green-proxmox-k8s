data "vault_kv_secret_v2" "proxmox" {
  mount = "jenkins"
  name  = local.workspace["vault_environment"]
}
