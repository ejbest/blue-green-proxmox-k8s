data "kubectl_file_documents" "metrics_server_manifests" {
  content = file("${path.module}/manifests/metrics-server.yml")
}

resource "kubectl_manifest" "kubectl_apply_metrics_server" {
  count     = length(data.kubectl_file_documents.metrics_server_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.metrics_server_manifests.documents, count.index)
}
