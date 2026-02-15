resource "kubernetes_secret" "homepage_secret" {
  metadata {
    name      = "homepage-secret"
    namespace = "homepage"
  }

  data = {
    "qbittorrent-key"    = var.HOMEPAGE_VAR_QBITTORRENT_KEY
    "prowlarr-key"       = var.HOMEPAGE_VAR_PROWLARR_KEY
    "readarr-key"        = var.HOMEPAGE_VAR_READARR_KEY
    "audiobookshelf-key" = var.HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY
    "ical-url"           = var.HOMEPAGE_VAR_ICAL_URL
    "nzbget-key"         = var.HOMEPAGE_VAR_NZBGET_KEY
  }

  type = "Opaque"
}
