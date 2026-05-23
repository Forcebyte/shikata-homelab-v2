# Copilot Instructions

## Adding a new app to the cluster

1. Create directory: `k8s/apps/<app-name>/`
2. Create `deploy.yaml` with all app resources (Namespace, Deployments, Services, etc.)
3. Create `ingressroute.yaml` for Traefik ingress:
   - Use `rybbit` middleware (namespace: kube-system) for base routing
   - Add `github-oauth` middleware (namespace: kube-system) for authentication
   - Set external-dns annotation: `external-dns.alpha.kubernetes.io/hostname: <subdomain>.forcebyte.org`
4. Create `kustomization.yaml` listing the resources
5. Add `./app-name` to `k8s/apps/kustomization.yaml` resources list

Flux automatically picks up changes from the kustomization files.

## Storage for apps if needed

Use local-path storage class for persistent volume claims. Example PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: audiobookshelf-metadata
  namespace: audiobookshelf
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-path
```

Obviously, update this as needed, note that we do not need a persistentvolume, just the claim, as local-path provisions them automatically.