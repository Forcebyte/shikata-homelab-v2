provider "kubernetes" {
  host                   = var.k8s_api_server
  token                  = var.k8s_api_token
  insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
}

provider "helm" {
    kubernetes {
        host                   = var.k8s_api_server
        token                  = var.k8s_api_token
        insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
    }
}