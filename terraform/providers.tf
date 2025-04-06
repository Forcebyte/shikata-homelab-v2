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


provider "flux" {
    kubernetes {
        host                   = var.k8s_api_server
        token                  = var.k8s_api_token
        insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
    }
    git = {
        url = "https://github.com/forcebyte/shikata-homelab-v2.git"
        http = {
            username = "git" # This can be any string when using a personal access token
            password = var.github_token
        }
    }
}


provider "github" {
  owner = "forcebyte"
  token = var.github_token
}

terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.5.1"
    }
  }
}
