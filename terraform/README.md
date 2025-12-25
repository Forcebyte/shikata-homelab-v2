# Terraform Configuration

This directory contains Terraform configurations for managing the Shikata Homelab v2 infrastructure, including FluxCD bootstrap, Kubernetes secrets, and application-specific resources.

## Overview

The Terraform configuration handles:

- **FluxCD Bootstrap**: Initializes FluxCD GitOps in the Kubernetes cluster
- **Secrets Management**: Creates Kubernetes secrets for various applications
- **Service Configuration**: Sets up OAuth, external DNS, and other services

## Prerequisites

- Terraform >= 1.0
- Access to a Kubernetes cluster (K3s/K8s on OCI)
- All required environment variables set (see [Required Variables](#required-variables))

## Required Variables

All variables are defined in `variables.tf`. Set them as environment variables with the `TF_VAR_` prefix:

### Core Kubernetes
- `TF_VAR_k8s_api_server`: Kubernetes API server URL (e.g., `https://10.0.1.216:6443`)
- `TF_VAR_k8s_api_token`: Kubernetes API authentication token

### Cloudflare (DNS Management)
- `TF_VAR_cloudflare_api_token`: Cloudflare API token for DNS operations
- `TF_VAR_cloudflare_api_key`: Cloudflare API key
- `TF_VAR_cloudflare_email`: Email associated with Cloudflare account

### GitHub Integration
- `TF_VAR_github_token`: GitHub Personal Access Token for repository access
- `TF_VAR_github_fluxcd_token`: GitHub token for FluxCD operations
- `TF_VAR_github_oauth_client_id`: GitHub OAuth client ID
- `TF_VAR_github_oauth_client_secret`: GitHub OAuth client secret
- `TF_VAR_headlamp_github_oauth_client_id`: GitHub OAuth client ID for Headlamp
- `TF_VAR_headlamp_github_oauth_client_secret`: GitHub OAuth client secret for Headlamp

### Application-Specific
- `TF_VAR_discord_webhook`: Discord webhook URL for notifications
- `TF_VAR_steam_api_key`: Steam API key (for CS2 server)
- `TF_VAR_steam_account_key`: Steam account key (for CS2 server)
- `TF_VAR_rcon_secret`: RCON password for game servers
- `TF_VAR_openwebui_secret_key`: Secret key for OpenWebUI application

## File Structure

```
terraform/
├── providers.tf          # Terraform and provider configuration
├── variables.tf          # Variable definitions
├── flux.tf               # FluxCD bootstrap and core secrets
├── external-dns.tf       # External DNS configuration
├── github-oauth.tf       # GitHub OAuth middleware setup
├── headlamp-oauth.tf     # Headlamp OAuth configuration
├── traefik.tf            # Traefik ingress controller secrets
├── cs2.tf                # Counter-Strike 2 server secrets
└── openwebui.tf          # OpenWebUI application secrets
```

## Usage

### Initial Setup

```bash
cd terraform/

# Initialize Terraform (download providers)
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

### Updating Configuration

```bash
# After making changes to .tf files
terraform plan

# Apply changes
terraform apply

# Or target specific resource
terraform apply -target=kubernetes_secret.example
```

### Validating Configuration

```bash
# Format check
terraform fmt -check -recursive

# Format all files
terraform fmt -recursive

# Validate configuration
terraform init -backend=false
terraform validate

# Run TFLint
tflint --init
tflint
```

## Providers

### Kubernetes Provider

Connects to the Kubernetes cluster to manage resources.

```hcl
provider "kubernetes" {
  host   = var.k8s_api_server
  token  = var.k8s_api_token
  insecure = true  # Certificate validation disabled
}
```

**Note**: `insecure = true` is used because the K8s certificate is only valid for internal IPs. In production, consider using proper certificate validation.

### Helm Provider

Manages Helm chart deployments.

```hcl
provider "helm" {
  kubernetes {
    host   = var.k8s_api_server
    token  = var.k8s_api_token
    insecure = true
  }
}
```

### Flux Provider

Handles FluxCD bootstrap and configuration.

```hcl
provider "flux" {
  kubernetes = { ... }
  git = {
    url = "https://github.com/forcebyte/shikata-homelab-v2.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}
```

### GitHub Provider

Manages GitHub repository resources and webhooks.

## Key Resources

### FluxCD Bootstrap

**File**: `flux.tf`

```hcl
resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "k8s/apps"
  interval           = "30s"
}
```

Bootstraps FluxCD to watch the `k8s/apps` directory and sync every 30 seconds.

### Secrets Management

Secrets are created as Kubernetes secrets in appropriate namespaces:

- **Discord Webhook**: Notification integration (flux-system, keel namespaces)
- **GitHub Token**: Repository access for FluxCD
- **Cloudflare Credentials**: DNS management for external-dns
- **OAuth Credentials**: Authentication for web applications
- **Application Secrets**: Service-specific credentials

Example:
```hcl
resource "kubernetes_secret" "discord_webhook" {
  metadata {
    name      = "discord-webhook"
    namespace = "flux-system"
  }
  data = {
    "address" = var.discord_webhook
  }
  type = "Opaque"
}
```

## Security Considerations

1. **Never commit secrets**: All secrets are managed via environment variables
2. **Sensitive variables**: Marked as `sensitive = true` in variables.tf
3. **State files**: Keep Terraform state files secure (not committed to git)
4. **Token rotation**: Regularly rotate API tokens and passwords
5. **Minimal permissions**: Use tokens with minimal required permissions

## Troubleshooting

### Authentication Errors

```bash
# Verify Kubernetes connectivity
kubectl --server=$TF_VAR_k8s_api_server --token=$TF_VAR_k8s_api_token get nodes

# Test with insecure flag if certificate issues
kubectl --server=$TF_VAR_k8s_api_server --token=$TF_VAR_k8s_api_token --insecure-skip-tls-verify get nodes
```

### State Lock Issues

```bash
# If state is locked
terraform force-unlock <lock-id>
```

### Provider Issues

```bash
# Reinitialize providers
rm -rf .terraform/
terraform init

# Upgrade providers
terraform init -upgrade
```

### Resource Already Exists

```bash
# Import existing resource
terraform import <resource_type>.<resource_name> <resource_id>

# Example
terraform import kubernetes_secret.example default/example-secret
```

## Testing Changes

Before applying to production:

1. Validate syntax: `terraform validate`
2. Check formatting: `terraform fmt -check`
3. Review plan: `terraform plan`
4. Test in a non-production cluster if possible

## Adding New Resources

1. Create a new `.tf` file or add to an existing one
2. Define required variables in `variables.tf`
3. Add documentation comments
4. Test locally: `terraform plan`
5. Submit PR for review

Example:
```hcl
# new-service.tf

# Secret for new service
resource "kubernetes_secret" "new_service" {
  metadata {
    name      = "new-service-credentials"
    namespace = "default"
  }

  data = {
    "username" = var.new_service_username
    "password" = var.new_service_password
  }

  type = "kubernetes.io/basic-auth"
}
```

## CI/CD Integration

Terraform changes are automatically validated via GitHub Actions:

- Format checking
- Validation
- TFLint static analysis
- PR comments with plan output

See `.github/workflows/terraform-lint.yml` for details.

## Additional Resources

- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [FluxCD Provider](https://registry.terraform.io/providers/fluxcd/flux/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
