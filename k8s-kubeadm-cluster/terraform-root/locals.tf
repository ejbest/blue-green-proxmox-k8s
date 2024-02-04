locals {
  env = {
    k8s-kubeadm-cluster-blue = {
      vault_secret_path     = "kubeadm-cluster/kubeadm-blue"
      vault_environment     = "blue"
      worker_ssh_user       = "blue_workernode_ssh_user"
      worker_ssh_pass       = "blue_workernode_ssh_pass"
      worker_ssh_host       = "blue_workernode_hostname"
      controlplane_ssh_user = "blue_controlplane_ssh_user"
      controlplane_ssh_pass = "blue_controlplane_ssh_pass"
      controlplane_ssh_host = "blue_controlplane_hostname"
    }
    k8s-kubeadm-cluster-green = {
      vault_secret_path     = "kubeadm-cluster/kubeadm-green"
      vault_environment     = "green"
      worker_ssh_user       = "green_workernode_ssh_user"
      worker_ssh_pass       = "green_workernode_ssh_pass"
      worker_ssh_host       = "green_workernode_hostname"
      controlplane_ssh_user = "green_controlplane_ssh_user"
      controlplane_ssh_pass = "green_controlplane_ssh_pass"
      controlplane_ssh_host = "green_controlplane_hostname"
    }
  }

  workspace = local.env[terraform.workspace]
}
