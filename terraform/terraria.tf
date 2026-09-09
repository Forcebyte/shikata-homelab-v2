resource "kubernetes_secret" "terraria" {
  metadata {
    name      = "terraria-server-secret"
    namespace = "terraria"
  }

  data = {
    "password"       = var.wildcard_server_connection_secret
  }

  type = "Opaque"
}
