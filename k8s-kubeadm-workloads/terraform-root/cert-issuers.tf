resource "kubectl_manifest" "auto-deploy-clusterissuer" {
  depends_on = [helm_release.cert-manager, kubectl_manifest.ej-proton-cloudflare-secret]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-production-auto-deploy
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-production-auto-deploy
        solvers:
        - selector:
            dnsZones:
              - "auto-deploy.net"
          dns01:
            cloudflare:
              email: ej.best@protonmail.com
              apiKeySecretRef:
                name: ej-proton-cloudflare-api-key-secret
                key: api-key
  YAML
}

resource "kubectl_manifest" "advocatediablo-clusterissuer" {
  depends_on = [helm_release.cert-manager, kubectl_manifest.ej-gm-cloudflare-secret]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod-advocatediablo
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-prod-advocatediablo
        solvers:
        - selector:
            dnsZones:
              - "advocatediablo.com"
          dns01:
            cloudflare:
              email: ej.best@pm.me
              apiKeySecretRef:
                name: ej-pm-cloudflare-api-key-secret
                key: api-key
  YAML
}
resource "kubectl_manifest" "nextresearch-clusterissuer" {
  depends_on = [helm_release.cert-manager, kubectl_manifest.ej-gm-cloudflare-secret]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-production-nextresearch
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-production-nextresearch
        solvers:
        - selector:
            dnsZones:
              - "nextresearch.io"
          dns01:
            cloudflare:
              email: erich.ej.best@gmail.com
              apiKeySecretRef:
                name: ej-gm-cloudflare-api-key-secret
                key: api-key
  YAML
}
