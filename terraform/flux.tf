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
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  repository = "https://fluxcd-community.github.io/helm-charts"
}


resource "kubernetes_manifest" "flux_gitrepository" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta2"
    kind       = "GitRepository"
    metadata = {
      name      = "shikata-homelab"
      namespace = "flux-system"
    }
    spec = {
      url        = "https://github.com/forcebyte/shikata-homelab.git"
      branch     = "main"
      secretRef  = {
        name = kubernetes_secret.flux_git_credentials.metadata[0].name
      }
    }
  }
}
