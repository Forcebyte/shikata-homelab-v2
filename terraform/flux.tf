resource "kubernetes_namespace" "flux-system" {
  metadata {
    name = "flux-system"
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]

  embedded_manifests = true
  path               = "k8s/apps"
}