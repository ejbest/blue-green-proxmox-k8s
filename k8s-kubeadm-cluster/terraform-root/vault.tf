data "vault_generic_secret" "kubeadm" {
  path = local.workspace["vault_secret_path"]
}
