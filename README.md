<div align="center">

<img src=".github/logo.png" alt="Shikata Homelab Logo" width="200"/>

# Shikata Homelab (v2)

<p><i>Homelab Configurations for Shikata, a OCI-Based HomeLab I use for random stuff</i></p>

</div>


## What is this?

Originally, back in ~2021, I had a fairly large homelab within my apartment which contained a ProxMox instance and a bunch of created configurations and systems, this is mostly documented under [my GitHub site I barely use](https://forcebyte.github.io/posts/2021-17-01-shikata-homelab-2/) - overall, it worked, but as I moved from place to place this became more and more annoying to keep up - specifically; the overall power draw from servers and costs associated to it became a bit of an annoyance for something I don't use as often as i'd like (outside of a few systems)

Thus, in 2025, I decided to try to replicate this into a single set of OCI (Oracle Cloud) free-tier instances, and perform most of the GitOps operations in a MonoRepo.


### How does this work?

In general, this repository is split into the following:

```
> shikata-homelab-v2
├───k8s
│   └───apps                 # Contains Flux configurations for various homelab projects
│       ├───calibre
|       ...
│       ├───flux-system
│       └───traefik-addons
├───qemu                     # Contains a Qemu hypervisor for ARM -> AMD Support
└───terraform                # Contains TFE code for secret additions to the cluster
```

The *Terraform* configuration does two things, specifically:
- Adds individual secrets (Cloudflare Tokens, Prowlarr/Sonarr) to namespaces
- Set up flux default config pointing to k8s folder

the *k8s* folder is FluxCD's base folder

### Why?

A few reasons, specifically:
- OCI's free tier is very good, the same amount of compute at my datacenter can be sufficiently done using the Ampere instances that can replace it easily
- Outside of storage, the free-tier connectivity and availability is way better than local
- Power and consumption costs are pretty much eliminated, allowing like-for-like utilization of services

The only *real* limitation of this is storage costs, at the moment my homelab doesnt have a large amount of storage requirements, but i'll likely have to figure out a good storage mirroring solution down the road (syncthing, etc)

### Other Notes

- Flux auto-syncs this repository every 30 seconds
- Terraform plan/applies this repository on file changes to the `terraform` folder

## Prerequisites

Before you can deploy this homelab, you'll need:

- **Oracle Cloud Infrastructure (OCI) Account**: Free tier account with Ampere ARM instances provisioned
- **Kubernetes Cluster**: A K3s or K8s cluster running on your OCI instances
- **Terraform**: Version >= 1.0 installed locally
- **kubectl**: Kubernetes CLI tool for cluster interaction
- **FluxCD**: GitOps operator for continuous deployment
- **Domain Name**: For external access (configured via Cloudflare)
- **GitHub Account**: For OAuth and repository access

### Required Secrets

The following environment variables/secrets are required for Terraform:

- `TF_VAR_k8s_api_server`: Your Kubernetes API server URL
- `TF_VAR_k8s_api_token`: Kubernetes API authentication token
- `TF_VAR_cloudflare_api_token`: Cloudflare API token for DNS management
- `TF_VAR_cloudflare_api_key`: Cloudflare API key
- `TF_VAR_cloudflare_email`: Email associated with Cloudflare account
- `TF_VAR_github_token`: GitHub Personal Access Token
- `TF_VAR_discord_webhook`: Discord webhook URL for notifications
- Additional secrets as defined in `terraform/variables.tf`

## Getting Started

### 1. Initial Setup

```bash
# Clone the repository
git clone https://github.com/forcebyte/shikata-homelab-v2.git
cd shikata-homelab-v2

# Set up your environment variables
export TF_VAR_k8s_api_server="https://your-k8s-api:6443"
export TF_VAR_k8s_api_token="your-token"
# ... set other required variables
```

### 2. Deploy Infrastructure with Terraform

```bash
cd terraform/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

This will:
- Bootstrap FluxCD in your cluster
- Create necessary Kubernetes secrets
- Configure external-dns, OAuth, and other core services

### 3. FluxCD Auto-Sync

Once Terraform is applied, FluxCD will automatically:
- Sync the `k8s/apps` directory every 30 seconds
- Deploy all applications defined in the Kustomization files
- Manage updates and reconciliation

### 4. Verify Deployment

```bash
# Check FluxCD status
kubectl get kustomizations -n flux-system

# Check deployed applications
kubectl get pods -A

# View specific app
kubectl get all -n <namespace>
```

## Repository Structure

```
shikata-homelab-v2/
├── .github/
│   └── workflows/          # CI/CD workflows for linting and validation
├── k8s/
│   ├── apps/               # Application deployments managed by FluxCD
│   │   ├── calibre/        # E-book management
│   │   ├── nextcloud/      # Personal cloud storage
│   │   ├── homepage/       # Dashboard
│   │   ├── traefik-addons/ # Ingress controller addons
│   │   └── ...             # Other applications
│   └── init.yaml           # FluxCD initialization
├── qemu/                   # Multi-architecture support (ARM->AMD)
│   ├── daemonset.yaml      # QEMU user-static daemonset
│   └── kustomization.yaml
├── terraform/              # Infrastructure as Code
│   ├── providers.tf        # Terraform providers configuration
│   ├── variables.tf        # Variable definitions
│   ├── flux.tf             # FluxCD bootstrap
│   └── *.tf                # Application-specific resources
└── README.md
```

## Adding New Applications

1. Create a new directory under `k8s/apps/<app-name>/`
2. Add your Kubernetes manifests (deployment, service, etc.)
3. Create a `kustomization.yaml` file
4. Add the app to `k8s/apps/kustomization.yaml`
5. Commit and push - FluxCD will auto-deploy

Example structure:
```yaml
# k8s/apps/myapp/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deploy.yaml
```

## Troubleshooting

### FluxCD Not Syncing

```bash
# Check Flux logs
kubectl logs -n flux-system -l app=source-controller

# Force reconciliation
flux reconcile source git flux-system
```

### Application Not Deploying

```bash
# Check kustomization status
kubectl describe kustomization <app-name> -n flux-system

# Validate kustomization locally
cd k8s/apps/<app-name>
kustomize build .
```

### Terraform Issues

```bash
# Check Terraform state
terraform show

# Re-apply specific resource
terraform apply -target=<resource>
```

## CI/CD

This repository includes automated workflows:

- **Kubernetes Lint**: Validates all Kubernetes manifests with kustomize, kubeconform, and Polaris
- **Terraform Lint**: Checks Terraform formatting and validates configuration
- **Code Quality**: Lints markdown and validates repository structure
- **Secrets Detection**: Scans for accidentally committed secrets

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

