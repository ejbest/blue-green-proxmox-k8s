locals {
  env = {
    k8s-kubeadm-cluster-blue-init = {
      vault_environment = "proxmox-blue"
      tf_backend        = "k8s-kubeadm-cluster-blue.conf"
      tf_workspace      = "k8s-kubeadm-cluster-blue"
    }
    k8s-kubeadm-cluster-green-init = {
      vault_environment = "proxmox-green"
      tf_backend        = "k8s-kubeadm-cluster-green.conf"
      tf_workspace      = "k8s-kubeadm-cluster-green"
    }
  }

  workspace = local.env[terraform.workspace]
}
