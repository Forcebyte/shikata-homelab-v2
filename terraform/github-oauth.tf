resource "kubernetes_secret" "cloudflare_api_token-kubesystem" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "kube-system"
  }

  data = {
    "clientId" = var.github_oauth_client_id
    "clientSecret" = var.github_oauth_client_secret
  }

  type = "Opaque"
}
