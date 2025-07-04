resource "kubernetes_secret" "cs2-secrets" {
  metadata {
    name      = "cs2-secrets"
    namespace = "game-server"
  }

  data = {
    "steamAccount" = var.steam_account_key
    "apiKey" = var.steam_api_key
  }

  type = "Opaque"
}
