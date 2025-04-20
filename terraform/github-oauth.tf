resource "kubernetes_secret" "traefik_github_oauth-kubesystem" {
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
