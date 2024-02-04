resource "kubectl_manifest" "ej-proton-cloudflare-secret" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ej-proton-cloudflare-api-key-secret
      namespace: cert-manager
    type: Opaque
    stringData:
      api-key: ${data.vault_generic_secret.kubeadm.data["cloudflare_proton_token"]}
  YAML
}

resource "kubectl_manifest" "ej-pm-cloudflare-secret" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ej-pm-cloudflare-api-key-secret
      namespace: cert-manager
    type: Opaque
    stringData:
      api-key: ${data.vault_generic_secret.kubeadm.data["cloudflare_pm_token"]}
  YAML
}
resource "kubectl_manifest" "ej-gm-cloudflare-secret" {
  yaml_body = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ej-gm-cloudflare-api-key-secret
      namespace: cert-manager
    type: Opaque
    stringData:
      api-key: ${data.vault_generic_secret.kubeadm.data["cloudflare_gmail_token"]}
  YAML
}
