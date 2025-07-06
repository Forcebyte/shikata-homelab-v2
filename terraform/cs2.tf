resource "kubernetes_namespace" "rcon" {
  metadata {
    name = "rcon"
  }
}

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


resource "kubernetes_secret" "rcon-secrets" {
  metadata {
    name      = "rcon-secrets"
    namespace = "rcon"
  }

  data = {
    "rcon-password" = var.rcon_secret
  }

  type = "Opaque"
}
