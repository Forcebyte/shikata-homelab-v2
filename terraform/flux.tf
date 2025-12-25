# FluxCD Bootstrap Configuration
# Initializes FluxCD in the cluster with GitOps configuration
# FluxCD will monitor the k8s/apps directory and sync changes every 30 seconds
resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "k8s/apps"
  interval           = "30s"
}


# Discord Webhook Secret for FluxCD Notifications
# Used by FluxCD to send notifications about deployments and errors
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

# Discord Webhook Secret for Keel
# Keel uses this to send notifications about container updates
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


# GitHub Token Secret for FluxCD
# Allows FluxCD to access private repositories and send status updates
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
