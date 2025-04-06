resource "kubernetes_secret" "cloudflare_api_token-kubesystem" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "kube-system"
  }

  data = {
    #"api-token" = var.cloudflare_api_token
    "api-token" = var.cloudflare_api_key
    "email" = var.cloudflare_email
  }

  type = "Opaque"
}
