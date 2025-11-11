resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "k8s/apps"
  interval           = "30s"
}


resource "kubernetes_secret" "discord_webhook" {
  metadata {
    name      = "discord-webhook"
    namespace = "flux-system"
  }

  data = {
    "address" = var.discord_webhook
  }

  type = "Opaque"
}
