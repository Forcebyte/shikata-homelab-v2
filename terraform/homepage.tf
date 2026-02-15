resource "kubernetes_secret" "homepage_secret" {
  metadata {
    name      = "homepage-secret"
    namespace = "homepage"
  }

  data = {
    "qbittorrent-key" = var.homepage_qbittorrent_key
  }

  type = "Opaque"
}
