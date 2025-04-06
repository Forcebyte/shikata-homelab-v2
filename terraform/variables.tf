variable "k8s_api_server" {
  description = "The URL to the Kubernetes API server"
  type        = string
}

variable "k8s_api_token" {
  description = "The Kubernetes API token for authentication"
  type        = string
  sensitive   = true
}

variable "ca_certificate" {
  description = "The CA certificate for the Kubernetes cluster (base64-encoded)"
  type        = string
  sensitive   = true
}


variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Cloudflare Email"
  type        = string
}



variable "github_token" {
  description = "Github PAT (https://github.com/settings/tokens)"
  type        = string
  sensitive   = true
}
