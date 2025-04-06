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
