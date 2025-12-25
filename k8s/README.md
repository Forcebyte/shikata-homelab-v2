# Kubernetes Applications

This directory contains all Kubernetes application manifests managed by FluxCD for the Shikata Homelab v2.

## Overview

The `k8s` directory is the source of truth for all applications deployed to the cluster. FluxCD continuously monitors this directory and automatically applies any changes within 30 seconds.

## Directory Structure

```
k8s/
├── apps/                    # Application manifests
│   ├── audiobookshelf/      # Audiobook server
│   ├── auto-upgrade/        # Automatic system upgrades
│   ├── calibre/             # E-book management and server
│   ├── cs2/                 # Counter-Strike 2 game server
│   ├── darkroom/            # Photo management
│   ├── external-dns/        # Automatic DNS management
│   ├── flux-system/         # FluxCD system components
│   ├── github-oauth/        # GitHub OAuth middleware
│   ├── headlamp/            # Kubernetes dashboard
│   ├── homepage/            # Homepage dashboard
│   ├── keel/                # Container update automation
│   ├── minecraft/           # Minecraft server
│   ├── nextcloud/           # Personal cloud storage
│   ├── nginx/               # Web server
│   ├── notifications/       # Notification system
│   ├── openwebui/           # OpenWebUI application
│   ├── prowlarr/            # Indexer manager
│   ├── qbittorrent/         # Torrent client
│   ├── rcon/                # Remote console for game servers
│   ├── readarr/             # E-book/audiobook collection manager
│   ├── rybbit/              # Custom application
│   ├── toolbox/             # Utility container
│   ├── traefik-addons/      # Traefik ingress addons
│   └── kustomization.yaml   # Main kustomization file
└── init.yaml                # FluxCD initialization configuration
```

## How It Works

### FluxCD GitOps Flow

1. **Repository Watch**: FluxCD watches this GitHub repository
2. **Sync Interval**: Checks for changes every 30 seconds (configured in Terraform)
3. **Reconciliation**: Applies any changes to the cluster automatically
4. **Status Reporting**: Reports sync status and any errors

### Kustomize

All applications use Kustomize for configuration management:

- Each app has its own `kustomization.yaml`
- The root `apps/kustomization.yaml` includes all applications
- Allows for easy configuration overlays and patches

## Application Structure

Each application typically includes:

```
app-name/
├── kustomization.yaml    # Kustomize configuration
├── namespace.yaml        # Namespace definition (if needed)
├── deploy.yaml           # Deployment and related resources
├── configmap.yaml        # Configuration data (if needed)
└── ingressroute.yaml     # Traefik ingress (if exposed)
```

### Example Application

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deploy.yaml

# deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-image:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: my-namespace
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

## Adding a New Application

### Step 1: Create Application Directory

```bash
mkdir -p k8s/apps/my-new-app
cd k8s/apps/my-new-app
```

### Step 2: Create Kubernetes Manifests

Create your deployment, service, and other resources:

```yaml
# namespace.yaml (if needed)
apiVersion: v1
kind: Namespace
metadata:
  name: my-app

---
# deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-app
spec:
  # ... deployment spec
```

### Step 3: Create Kustomization

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deploy.yaml
```

### Step 4: Add to Root Kustomization

Edit `k8s/apps/kustomization.yaml` and add your app:

```yaml
resources:
  # ... existing apps
  - ./my-new-app
```

### Step 5: Commit and Push

```bash
git add k8s/apps/my-new-app/
git commit -m "Add my-new-app"
git push
```

FluxCD will detect and deploy your application within 30 seconds!

## Testing Locally

Before committing, validate your manifests:

```bash
# Validate kustomization builds
cd k8s/apps/my-new-app
kustomize build .

# Validate with kubeconform
kustomize build . | kubeconform -strict -

# Test with kubectl (dry-run)
kustomize build . | kubectl apply --dry-run=client -f -
```

## Common Patterns

### Persistent Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: my-namespace
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-path
```

### Traefik Ingress

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-app
  namespace: my-namespace
  annotations:
    external-dns.alpha.kubernetes.io/target: myapp.forcebyte.org
    kubernetes.io/ingress.class: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`myapp.forcebyte.org`)
      kind: Rule
      services:
        - name: my-app
          port: 80
```

### GitHub OAuth Protection

Add GitHub OAuth middleware to restrict access:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-app
  namespace: my-namespace
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`myapp.forcebyte.org`)
      kind: Rule
      middlewares:
        - name: github-oauth
          namespace: kube-system
      services:
        - name: my-app
          port: 80
```

### Auto-Updates with Keel

Enable automatic image updates:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-namespace
  annotations:
    keel.sh/policy: force
    keel.sh/trigger: poll
spec:
  # ... rest of deployment
```

## Special Applications

### flux-system

Contains FluxCD's own configuration. Generally should not be modified manually as it's managed by the Flux Terraform provider.

### external-dns

Automatically manages DNS records in Cloudflare based on ingress annotations.

### traefik-addons

Contains middleware and other Traefik enhancements like OAuth.

### keel

Automates container image updates for deployments with appropriate annotations.

## Monitoring Deployments

### Check FluxCD Status

```bash
# List all kustomizations
kubectl get kustomizations -n flux-system

# Check specific app status
kubectl describe kustomization my-app -n flux-system

# View FluxCD logs
kubectl logs -n flux-system -l app=kustomize-controller -f
```

### Check Application Status

```bash
# List all resources in namespace
kubectl get all -n my-namespace

# Check pod logs
kubectl logs -n my-namespace -l app=my-app

# Describe deployment
kubectl describe deployment my-app -n my-namespace
```

### Force Reconciliation

```bash
# Force FluxCD to sync immediately
flux reconcile source git flux-system

# Reconcile specific kustomization
flux reconcile kustomization my-app
```

## Troubleshooting

### Application Not Deploying

1. **Check FluxCD Status**:
   ```bash
   kubectl get kustomizations -n flux-system
   kubectl describe kustomization <app-name> -n flux-system
   ```

2. **Validate Kustomization**:
   ```bash
   cd k8s/apps/<app-name>
   kustomize build .
   ```

3. **Check Events**:
   ```bash
   kubectl get events -n <namespace> --sort-by='.lastTimestamp'
   ```

### Image Pull Errors

```bash
# Check image pull secrets
kubectl get secrets -n <namespace>

# View pod details
kubectl describe pod <pod-name> -n <namespace>
```

### Resource Limits

```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n <namespace>
```

### DNS Issues

```bash
# Check external-dns logs
kubectl logs -n external-dns -l app=external-dns

# Verify DNS records in Cloudflare
```

## Best Practices

1. **Namespaces**: Use separate namespaces for logical grouping
2. **Labels**: Add consistent labels for easier management
3. **Resource Limits**: Always set CPU and memory limits
4. **Health Checks**: Define liveness and readiness probes
5. **Security**: Use non-root users when possible
6. **Secrets**: Store secrets in Kubernetes secrets (managed by Terraform)
7. **Documentation**: Comment complex configurations
8. **Testing**: Validate locally before committing

## Security Considerations

- Secrets are managed via Terraform (see `terraform/` directory)
- OAuth authentication available via GitHub middleware
- Use NetworkPolicies for network segmentation (if needed)
- Regular security scanning via Trivy in CI/CD
- Keep container images updated (automated via Keel)

## Additional Resources

- [FluxCD Documentation](https://fluxcd.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
