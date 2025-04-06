provider "kubernetes" {
  host                   = var.k8s_api_server
  cluster_ca_certificate = base64decode(var.ca_certificate)
  token                  = var.k8s_api_token
}