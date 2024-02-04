// kubernetes provider configuration
provider "kubernetes" {
  config_path            = local.workspace["kube_config"]
  config_context_cluster = local.workspace["cluster_name"]
}

provider "kubectl" {
  config_path            = local.workspace["kube_config"]
  config_context_cluster = local.workspace["cluster_name"]
}

// add helm provider
provider "helm" {
  kubernetes {
    config_path = local.workspace["kube_config"]
  }
}

provider "vault" {
  skip_tls_verify = true
  address         = var.vault_addr
  token           = var.vault_token
}

data "vault_generic_secret" "kubeadm" {
  path = local.workspace["vault_secret_path"]
}

