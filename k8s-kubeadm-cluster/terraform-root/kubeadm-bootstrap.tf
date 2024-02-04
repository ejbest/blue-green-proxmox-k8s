resource "null_resource" "kubeadm-controlplane" {
  triggers = {
    key = uuid()
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.kubeadm.data["${local.workspace["controlplane_ssh_user"]}"]
    password = data.vault_generic_secret.kubeadm.data["${local.workspace["controlplane_ssh_pass"]}"]
    host     = data.vault_generic_secret.kubeadm.data["${local.workspace["controlplane_ssh_host"]}"]
  }

  provisioner "file" {
    source      = "scripts/get_helm.sh"
    destination = "/tmp/get_helm.sh"
  }
  provisioner "file" {
    source      = "scripts/k8s-1-27.sh"
    destination = "/tmp/k8s-1-27.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/get_helm.sh",
      "/tmp/get_helm.sh",
      "chmod +x /tmp/k8s-1-27.sh",
      "/tmp/k8s-1-27.sh",
      "sudo kubeadm token create --print-join-command > /tmp/join_command; sed -i '1s/^/sudo /' /tmp/join_command",
      "sshpass -p '${data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_pass"]}"]}' scp /tmp/join_command ${data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_user"]}"]}@${data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_host"]}"]}:/tmp/join_command"

    ]
  }
}

