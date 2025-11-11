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

# Github token for FluxCD
variable "github_token" {
  description = "Github PAT (https://github.com/settings/tokens)"
  type        = string
  sensitive   = true
}

# Github OAuth Client ID and Secret for FluxCD
variable "github_oauth_client_id" {
  description = "Github OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "github_oauth_client_secret" {
  description = "Github OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "steam_api_key" {
  description = "Steam API Key"
  type        = string
  sensitive   = true
}

variable "steam_account_key" {
  description = "Steam Account API Key"
  type        = string
  sensitive   = true
}

variable "rcon_secret" {
  description = "RCON Password for CS2"
  type        = string
  sensitive   = true
}

variable "discord_webhook" {
  description = "Discord Webhook URL"
  type        = string
  sensitive   = true
}

variable "github_fluxcd_token" {
  description = "Github Personal Access Token"
  type        = string
  sensitive   = true
}

variable "openwebui_secret_key" {
  description = "Secret key for OpenWebUI"
  type        = string
  sensitive   = true
}

# Standard Notes variables
variable "standardnotes_db_password" {
  description = "Database password for Standard Notes"
  type        = string
  sensitive   = true
}

variable "standardnotes_mysql_root_password" {
  description = "MySQL root password for Standard Notes database"
  type        = string
  sensitive   = true
}

variable "standardnotes_jwt_secret" {
  description = "JWT secret for Standard Notes authentication"
  type        = string
  sensitive   = true
}

variable "standardnotes_server_key" {
  description = "Server encryption key for Standard Notes"
  type        = string
  sensitive   = true
}

variable "standardnotes_valet_token" {
  description = "Valet token secret for Standard Notes"
  type        = string
  sensitive   = true
}