# Kubernetes Provider Configuration
# Connects to the K8s cluster to manage resources like secrets, deployments, etc.
provider "kubernetes" {
  host                   = var.k8s_api_server
  token                  = var.k8s_api_token
  insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
}

# Helm Provider Configuration  
# Used for deploying Helm charts to the Kubernetes cluster
provider "helm" {
    kubernetes {
        host                   = var.k8s_api_server
        token                  = var.k8s_api_token
        insecure               = true # certificate is valid for 10.0.1.216, 10.43.0.1, 127.0.0.1, ::1, not xyz
    }
}


# Flux Provider Configuration
# Handles FluxCD GitOps bootstrap and configuration
# Monitors the GitHub repository and syncs k8s/apps directory to the cluster
provider "flux" {
    kubernetes = {
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


# GitHub Provider Configuration
# Manages GitHub repository resources and webhooks for notifications
provider "github" {
  owner = "forcebyte"
  token = var.github_token
}

# Terraform Configuration Block
# Defines required Terraform version and provider versions
terraform {
  required_version = ">= 1.0"
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
