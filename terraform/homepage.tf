resource "kubernetes_secret" "homepage_secret" {
  metadata {
    name      = "homepage-secret"
    namespace = "homepage"
  }

  data = {
    "qbittorrent-key" = var.HOMEPAGE_VAR_QBITTORRENT_KEY
  }

  type = "Opaque"
}
