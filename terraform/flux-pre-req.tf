resource "kubernetes_role" "secret_manager" {
  metadata {
    name      = "secret-manager"
    namespace = "default"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create", "update", "patch", "list"]
  }
}