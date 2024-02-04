// adding the certmanager into the clusters
resource "helm_release" "local-path-provisioner" {
  name       = "local-path-provisioner"
  repository = "helm/local-path-provisioner/chart"
  chart      = "local-path-provisioner"
  // clean up in case of failed install/upgrade
  cleanup_on_fail = true
  // create the namespace for deployment
  namespace = "local-path-provisioner"
  // create the namespace if it doesn't exist
  create_namespace = true
  values = [
    file("${path.module}/helm/helm-values/metallb-values.yaml")
  ]
}
