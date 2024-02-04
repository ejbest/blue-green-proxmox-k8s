resource "kubectl_manifest" "nextresearch-deployment" {
  depends_on = [kubectl_manifest.namespaces]
  yaml_body  = <<YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nextresearch
      namespace : nextresearch
    spec:
      selector:
        matchLabels:
          app: nextresearch
      template:
        metadata:
          labels:
            app: nextresearch
        spec:
          containers:
          - name: nextresearch
            image: ejbest/nextresearch:latest
            imagePullPolicy: Always
            resources:
              limits:
                memory: "128Mi"
                cpu: "100m"
            ports:
            - containerPort: 80
            - containerPort: 443
            # volumeMounts:
              # - name: nextresearch-html
              #   mountPath: /usr/share/nginx/html
          # volumes:
            # - name: nextresearch-html
            #   hostPath:
            #     path: /home/k8s/html
          restartPolicy: Always
  YAML
}

resource "kubectl_manifest" "nextresearch-service" {
  depends_on = [kubectl_manifest.nextresearch-deployment]
  yaml_body  = <<YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: nextresearch
      namespace : nextresearch
    spec:
      selector:
        app: nextresearch
      ports:
      - name: nextresearch
        protocol: TCP
        port: 443
        targetPort: 80
  YAML
}
resource "kubectl_manifest" "nextresearch-ingress" {
  depends_on = [kubectl_manifest.nextresearch-deployment]
  yaml_body  = <<YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: nextresearch
      namespace : nextresearch
      labels:
        name: nextresearch
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
        kubernetes.io/ingress.class: nginx
    spec:
      tls:
        - hosts:
            - ${local.workspace["nextresearch_ingress_dns"]}
          secretName: ${local.workspace["nextresearch_ingress_tls"]}
      rules:
      - host: ${local.workspace["nextresearch_ingress_dns"]}
        http:
          paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: nextresearch
                port: 
                  number: 443
  YAML
}

