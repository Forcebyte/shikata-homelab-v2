resource "kubernetes_namespace" "flux-system" {
  metadata {
    name = "flux-system"
  }
}

resource "kubernetes_secret" "flux_git_credentials" {
  metadata {
    name      = "flux-git-credentials"
    namespace = kubernetes_namespace.flux-system.metadata[0].name
  }

  data = {
    "api-token" = base64encode(var.github_token)
  }

  type = "Opaque"
}


resource "helm_release" "flux" {
  name       = "flux"
  namespace  = "flux-system"
  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = "1.23.0"  # Adjust according to the latest stable version
  create_namespace = true
}
