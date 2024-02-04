resource "null_resource" "kubeadmin-join-worker" {
  depends_on = [null_resource.kubeadm-controlplane]
  triggers = {
    key = uuid()
  }

  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_user"]}"]
    password = data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_pass"]}"]
    host     = data.vault_generic_secret.kubeadm.data["${local.workspace["worker_ssh_host"]}"]
  }

  provisioner "file" {
    source      = "scripts/k8s-1-27-worker.sh"
    destination = "/tmp/k8s-1-27-worker.sh"
  }
  # Only this command should run on worker
  provisioner "remote-exec" {
    inline = [
      "cat /tmp/join_command",
      "mv /tmp/join_command /tmp/join_command.sh",
      "chmod +x /tmp/k8s-1-27-worker.sh",
      "/tmp/k8s-1-27-worker.sh",
      "chmod +x /tmp/join_command.sh",
      "/tmp/join_command.sh"
    ]
  }
}

