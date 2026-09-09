variable "k8s_api_server" {
  description = "The URL to the Kubernetes API server"
  type        = string
}

variable "k8s_api_token" {
  description = "The Kubernetes API token for authentication"
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

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog App Key"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_QBITTORRENT_KEY" {
  description = "qBittorrent API key for Homepage"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_PROWLARR_KEY" {
  description = "Prowlarr API key for Homepage"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_READARR_KEY" {
  description = "Readarr API key for Homepage"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY" {
  description = "Audiobookshelf API key for Homepage"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_ICAL_URL" {
  description = "iCal URL for Homepage calendar widget"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_NZBGET_KEY" {
  description = "NZBGet API key for Homepage"
  type        = string
  sensitive   = true
}

variable "HOMEPAGE_VAR_CALIBRE_KEY" {
  description = "Calibre API key for Homepage"
  type        = string
  sensitive   = true
}

variable "doppelganger_session_secret" {
  description = "Session secret for Doppelganger"
  type        = string
  sensitive   = true
}

variable "wildcard_server_connection_secret" {
  description = "Session secret for All server connections that require a password (e.g. Terraria, etc.)"
  type        = string
  sensitive   = true
}

variable "terraria_calamity_password" {
  description = "Password for the Terraria Calamity server"
  type        = string
  sensitive   = true
}

variable "terraria_password" {
  description = "Password for the Terraria server"
  type        = string
  sensitive   = true
}