resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "k8s/apps"
  interval           = "30s"
}