resource "kubernetes_secret" "terraria-calamity" {
  metadata {
    name      = "terraria-server-secret"
    namespace = "terraria-calamity"
  }

  data = {
    "password" = var.wildcard_server_connection_secret
  }

  type = "Opaque"
}
