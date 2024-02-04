
resource "null_resource" "kubeadm" {
  /* triggers = {
    key = uuid()
  } */
  connection {
    type     = "ssh"
    user     = "k8s"
    password = data.vault_kv_secret_v2.proxmox.data["password"]
    host     = data.vault_kv_secret_v2.proxmox.data["host_1"]
  }

  provisioner "remote-exec" {
    inline = [
      "export TF_VAR_vault_token=${var.vault_token}",
      "export TF_VAR_vault_addr=${var.vault_addr}",
      "rm -rf ~/kubeadm-cluster",
      "git clone git@gitlab.com:advocatediablo/proxmox-kubernetes.git ~/kubeadm-cluster",
      "cd ~/kubeadm-cluster/k8s-kubeadm-cluster/terraform-root",
      "terraform init -upgrade -migrate-state -backend-config=backends/${local.workspace["tf_backend"]} ${var.common_backend}",
      "terraform workspace select ${local.workspace["tf_workspace"]} || terraform workspace new ${local.workspace["tf_workspace"]}",
      "terraform plan -lock=false",
      "terraform apply -lock=false --auto-approve",
    ]
  }

}
