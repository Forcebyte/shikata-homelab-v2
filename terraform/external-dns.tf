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
    "api-token" = var.cloudflare_api_token
    "api-key" = var.cloudflare_api_key
    "email" = var.cloudflare_email
  }

  type = "Opaque"
}
