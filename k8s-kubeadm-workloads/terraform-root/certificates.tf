# Jenkins auto-deploy
resource "kubectl_manifest" "jenkins-tls-auto-deploy-production" {
  depends_on = [kubectl_manifest.auto-deploy-clusterissuer]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: tls-auto-deploy-production
      namespace: jenkins
    spec:
      secretName: tls-auto-deploy-production
      issuerRef:
        name:  letsencrypt-production-auto-deploy
        kind: ClusterIssuer
      commonName: "jenkins.auto-deploy.net"
      dnsNames:
        - "jenkins.auto-deploy.net"
        - "auto-deploy.net"
  YAML
}

# Vault auto-deploy
resource "kubectl_manifest" "vault-tls-auto-deploy-production" {
  depends_on = [kubectl_manifest.auto-deploy-clusterissuer]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: tls-auto-deploy-production
      namespace: vault
    spec:
      secretName: tls-auto-deploy-production
      issuerRef:
        name:  letsencrypt-production-auto-deploy
        kind: ClusterIssuer
      commonName: "vault.auto-deploy.net"
      dnsNames:
        - "vault.auto-deploy.net"
        - "auto-deploy.net"
  YAML
}

resource "kubectl_manifest" "tls-nextresearch-production" {
  depends_on = [kubectl_manifest.nextresearch-clusterissuer]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: tls-nextresearch-production
      namespace: nextresearch
    spec:
      secretName: tls-nextresearch-production
      issuerRef:
        name:  letsencrypt-production-nextresearch
        kind: ClusterIssuer
      commonName: "*.nextresearch.io"
      dnsNames:
        - "*.nextresearch.io"
        - "nextresearch.io"
  YAML
}

# Jenkins auto-advocatediablo
resource "kubectl_manifest" "jenkins-tls-advocatediablo-production" {
  depends_on = [kubectl_manifest.advocatediablo-clusterissuer]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: tls-advocatediablo-production
      namespace: jenkins
    spec:
      secretName: tls-advocatediablo-production
      issuerRef:
        name:  letsencrypt-prod-advocatediablo
        kind: ClusterIssuer
      commonName: "jenkins.advocatediablo.com"
      dnsNames:
        - "jenkins.advocatediablo.com"
  YAML
}

# vault auto-advocatediablo
resource "kubectl_manifest" "vault-tls-advocatediablo-production" {
  depends_on = [kubectl_manifest.advocatediablo-clusterissuer]
  yaml_body  = <<YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: tls-advocatediablo-production
      namespace: vault
    spec:
      secretName: tls-advocatediablo-production
      issuerRef:
        name:  letsencrypt-prod-advocatediablo
        kind: ClusterIssuer
      commonName: "vault.advocatediablo.com"
      dnsNames:
        - "vault.advocatediablo.com"
  YAML
}

