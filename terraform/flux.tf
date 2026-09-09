resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  version            = "v2.6.4"
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

resource "kubernetes_secret" "discord_webhook_keel_copy" {
  metadata {
    name      = "discord-webhook"
    namespace = "keel"
  }

  data = {
    "address" = var.discord_webhook
  }

  type = "Opaque"
}


resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-token"
    namespace = "flux-system"
  }

  data = {
    "address" = var.github_fluxcd_token
  }

  type = "Opaque"
}
