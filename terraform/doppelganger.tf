resource "kubernetes_secret" "doppelganger" {
  metadata {
    name      = "doppelganger-secret"
    namespace = "doppelganger"
  }

  data = {
    "session_secret" = var.doppelganger_session_secret
  }

  type = "Opaque"
}
