locals {
  env = {
    k8s-kubeadm-workloads-blue = {
      kube_config              = "~/.kube/config"
      cluster_name             = "kubernetes"
      certmanager_version      = "1.11.0"
      nodeselector_hostname    = "blue-controlplane"
      jenkins_ingress_dns      = "jenkins.auto-deploy.net"
      jenkins_ingress_tls      = "tls-auto-deploy-production"
      vault_ingress_dns        = "vault.auto-deploy.net"
      vault_ingress_tls        = "tls-auto-deploy-production"
      nextresearch_ingress_tls = "tls-auto-deploy-production"
      nextresearch_ingress_dns = "nextresearch.auto-deploy.net"
      namespaces               = ["jenkins", "vault", "cert-manager", "nextresearch"]
      vault_secret_path        = "kubeadm-cluster/kubeadm-blue"
    }
    k8s-kubeadm-workloads-green = {
      kube_config              = "~/.kube/config"
      cluster_name             = "kubernetes"
      certmanager_version      = "1.11.0"
      nodeselector_hostname    = "green-control-plane"
      jenkins_ingress_dns      = "jenkins.advocatediablo.com"
      jenkins_ingress_tls      = "tls-advocatediablo-production"
      vault_ingress_dns        = "vault.advocatediablo.com"
      vault_ingress_tls        = "tls-advocatediablo-production"
      nextresearch_ingress_tls = "tls-advocatediablo-production"
      nextresearch_ingress_dns = "nextresearch.advocatediablo.com"
      namespaces               = ["jenkins", "vault", "cert-manager", "nextresearch"]
      vault_secret_path        = "kubeadm-cluster/kubeadm-green"
    }
  }

  workspace = local.env[terraform.workspace]
}
