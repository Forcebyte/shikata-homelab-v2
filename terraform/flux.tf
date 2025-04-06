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
    "identity" = base64encode(var.github_ssh_key)
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
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "shikata-homelab"
      namespace = "flux-system"
    }
    spec = {
      url        = "git@github.com:forcebyte/shikata-homelab-v2.git"
      ref = {
        branch = "main"
      }
      interval        = "1m"
      secretRef  = {
        name = kubernetes_secret.flux_git_credentials.metadata[0].name
      }
    }
  }
}
