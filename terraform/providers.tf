provider "kubernetes" {
  host                   = var.k8s_api_server
  cluster_ca_certificate = base64decode(var.ca_certificate)
  token                  = var.k8s_api_token
  insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
}