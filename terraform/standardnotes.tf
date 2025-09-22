resource "kubernetes_namespace" "standardnotes" {
  metadata {
    name = "standardnotes"
  }
}

resource "kubernetes_secret" "standardnotes-secrets" {
  metadata {
    name      = "standardnotes-secret"
    namespace = "standardnotes"
  }

  data = {
    "db-password"         = var.standardnotes_db_password
    "mysql-root-password" = var.standardnotes_mysql_root_password
    "jwt-secret"          = var.standardnotes_jwt_secret
  }

  type = "Opaque"
}
