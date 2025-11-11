resource "kubernetes_secret" "openwebui_secret" {
  metadata {
    name      = "openwebui-secret"
    namespace = "openwebui"
  }

  data = {
    "api-token" = var.openwebui_secret_key
  }

  type = "Opaque"
}
