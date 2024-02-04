// adding the certmanager into the clusters
resource "helm_release" "cert-manager" {
  depends_on = [kubectl_manifest.namespaces]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  // use the latest version of cert-manager
  version = local.workspace["certmanager_version"]
  // clean up in case of failed install/upgrade
  cleanup_on_fail = true
  // create the namespace for deployment
  namespace = "cert-manager"
  // create the namespace if it doesn't exist
  create_namespace = true
  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "cainjector.enabled"
    value = true
  }
  set {
    name  = "extraArgs"
    value = "{--dns01-recursive-nameservers-only=true}"
  }
}
