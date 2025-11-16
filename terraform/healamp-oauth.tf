resource "kubernetes_secret" "traefik_headlamp_github_oauth-kubesystem" {
  metadata {
    name      = "headlamp-github-oauth-secret"
    namespace = "kube-system"
  }

  data = {
    "clientId" = var.headlamp_github_oauth_client_id
    "clientSecret" = var.headlamp_github_oauth_client_secret
  }

  type = "Opaque"
}
