data "kubectl_file_documents" "vault_manifests" {
  content = file("${path.module}/manifests/vault.yml")
}

resource "kubectl_manifest" "kubectl_apply_vault" {
  for_each  = toset(data.kubectl_file_documents.vault_manifests.documents)
  yaml_body = each.value
}

resource "kubectl_manifest" "vault-ingress" {
  depends_on = [helm_release.ingress_nginx, kubectl_manifest.kubectl_apply_vault]
  yaml_body  = <<YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: vault
      namespace: vault
      labels:
        name: vault
    spec:
      tls:
        - hosts:
            - ${local.workspace["vault_ingress_dns"]}
          secretName: ${local.workspace["vault_ingress_tls"]}
      rules:
      - host: ${local.workspace["vault_ingress_dns"]}
        http:
          paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: vault
                port: 
                  number: 8200
    YAML
}

/* resource "kubectl_manifest" "vault-init" {
  depends_on = [kubectl_manifest.vault-ingress]
  yaml_body  = <<YAML
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: init-unseal-vault
      namespace: vault
    spec:
      completions: 1
      template:
        spec:
          initContainers:
          - name: init-install-jq
            image: alpine:latest
            securityContext:
              runAsRoot: true
            command: ["/bin/sh", "-c"]
            args:
              - apk --no-cache add jq
            volumeMounts:
            - name: vault-data
              mountPath: /vault/data

          containers:
          - name: vault-init
            image: hashicorp/vault:latest
            securityContext:
              runAsRoot: true
            command:
                - "/bin/sh"
                - "-c"
                - |
                  # Install jq
                  apk --no-cache add jq

                  # Set the VAULT_ADDR to the Vault service DNS name
                  export VAULT_ADDR=http://vault-0.vault-internal:8200

                  # Copy the Vault configuration to the correct path

                  # Initialize Vault and retrieve unseal keys and root token
                  vault operator init -format=json > /vault/data/init.json

                  sleep 10
                  # Extract unseal keys and root token
                  UNSEAL_KEYS=$(cat /vault/data/init.json | jq -r .unseal_keys_b64[])
                  ROOT_TOKEN=$(cat /vault/data/init.json | jq -r .root_token)

                  # Unseal Vault using the unseal keys
                  for key in $UNSEAL_KEYS; do
                    vault operator unseal $key
                  done

                  sleep 10

                  # Shutdown Vault server
                  kill $(pidof init-unseal-vaul)

            volumeMounts:
            - name: vault-data
              mountPath: /vault/data

          restartPolicy: OnFailure
          volumes:
          - name: vault-data
            emptyDir: {}
    YAML
}
 */

/* // adding the certmanager into the clusters
resource "helm_release" "vault" {
  depends_on = [helm_release.ingress_nginx]
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  // create the namespace if it doesn't exist
  create_namespace = true
  values = [
    templatefile(
      "${path.module}/helm/helm-values/vault.yml",
      {
        VAULT_INGRESS_TLS = local.workspace["vault_ingress_tls"]
        VAULT_INGRESS_DNS = local.workspace["vault_ingress_dns"]
      }
    )
  ]
} */
