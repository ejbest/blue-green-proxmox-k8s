locals {
  env = {
    k8s-kubeadm-workloads-blue-init = {
      vault_environment = "proxmox-blue"
      tf_backend        = "k8s-kubeadm-workloads-blue.conf"
      tf_workspace      = "k8s-kubeadm-workloads-blue"
    }
    k8s-kubeadm-workloads-green-init = {
      vault_environment = "proxmox-green"
      tf_backend        = "k8s-kubeadm-workloads-green.conf"
      tf_workspace      = "k8s-kubeadm-workloads-green"
    }
  }

  workspace = local.env[terraform.workspace]
}
