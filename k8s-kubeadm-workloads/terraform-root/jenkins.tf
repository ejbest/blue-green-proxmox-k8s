resource "kubectl_manifest" "jenkins-secret" {
  depends_on = [kubectl_manifest.namespaces]
  yaml_body  = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
        name: jenkins
        namespace: jenkins
    type: Opaque
    data:
        jenkins-password: ${data.vault_generic_secret.kubeadm.data["jenkins-password"]}
  YAML
}

data "kubectl_path_documents" "jenkins_manifests" {
  pattern = "./manifests/jenkins.yml"
  vars = {
    jenkins_ingress_dns = local.workspace["jenkins_ingress_dns"]
    jenkins_ingress_tls = local.workspace["jenkins_ingress_tls"]
  }
}

resource "kubectl_manifest" "kubectl_apply_jenkins" {
  count     = length(data.kubectl_path_documents.jenkins_manifests.documents)
  yaml_body = element(data.kubectl_path_documents.jenkins_manifests.documents, count.index)
}
