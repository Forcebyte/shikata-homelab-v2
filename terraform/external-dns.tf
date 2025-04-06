resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    "api-token" = base64encode(var.cloudflare_api_token)
  }

  type = "Opaque"
}


resource "kubernetes_manifest" "flux_kustomization" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1beta2"
    kind       = "Kustomization"
    metadata = {
      name      = "external-dns"
      namespace = "flux-system"
    }
    spec = {
      targetNamespace = kubernetes_namespace.external_dns.metadata[0].name
      path            = "./k8s/apps/external-dns"
      prune           = true
      interval        = "1m"
      gitRepositoryRef = {
        name = kubernetes_manifest.flux_gitrepository.metadata[0].name
      }
    }
  }
}
