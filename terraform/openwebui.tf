resource "kubernetes_secret_openai" "cloudflare_api_token-kubesystem" {
  metadata {
    name      = "openwebui-secret"
    namespace = "openwebui"
  }

  data = {
    "api-token" = var.openwebui_secret_key
  }

  type = "Opaque"
}
