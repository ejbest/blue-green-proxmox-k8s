resource "kubectl_manifest" "namespaces" {
  for_each  = toset(local.workspace["namespaces"])
  yaml_body = <<YAML
    apiVersion: v1
    kind: Namespace
    metadata:
        name: ${each.key}
  YAML
}
