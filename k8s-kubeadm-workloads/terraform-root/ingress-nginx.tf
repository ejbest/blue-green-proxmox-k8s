resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  values = [
    templatefile(
      "${path.module}/helm/helm-values/ingress-nginx.yaml",
      {
        NODESELECTOR_HOSTNAME = local.workspace["nodeselector_hostname"]
      }
    )
  ]
  set {
    name  = "rbac.create"
    value = "true"
  }
}

# cluster role definition for the service account
resource "kubernetes_cluster_role" "nginx-ingress-role" {
  metadata {
    name = "nginx-ingress-role"
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = ["", "coordination.k8s.io", "discovery.k8s.io", "networking.k8s.io", ""]
    resources  = ["endpointslices", "ingressclasses", "ingresses/status", "events", "ingresses", "services", "nodes", "leases", "namespaces", "endpoints", "configmaps", "pods", "secrets"]
  }
}

# bind the role to the service accounts
resource "kubernetes_cluster_role_binding" "nginx-ingress-binding" {

  metadata {
    name = "nginx-ingress-role-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nginx-ingress-role"
  }
}

resource "null_resource" "wait_for_ingress_nginx" {
  /* triggers = {
    key = uuid()
  } */

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}
