# QEMU Multi-Architecture Support

This directory contains Kubernetes configurations for enabling multi-architecture container support using QEMU user-mode emulation.

## Overview

Oracle Cloud Infrastructure (OCI) Ampere instances use ARM64 architecture. To run x86_64 (AMD64) container images on these ARM-based nodes, we use QEMU's `binfmt_misc` support to transparently emulate x86_64 instructions.

## What Does This Do?

The QEMU configuration:

- Registers binary format handlers in the kernel for various architectures
- Allows ARM64 nodes to run AMD64 container images transparently
- Enables running multi-architecture workloads without modification
- Uses `multiarch/qemu-user-static` container image

## Files

```
qemu/
├── daemonset.yaml       # DaemonSet that runs on all nodes
└── kustomization.yaml   # Kustomize configuration
```

## How It Works

### DaemonSet

The DaemonSet runs a privileged container on every node in the cluster:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: qemu-binfmt
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: qemu-binfmt
        image: multiarch/qemu-user-static
        args: ["--reset", "-p", "yes"]
        securityContext:
          privileged: true
        volumeMounts:
        - name: binfmt
          mountPath: /proc/sys/fs/binfmt_misc
```

### Key Components

1. **Image**: `multiarch/qemu-user-static`
   - Contains QEMU user-mode emulators
   - Registers binary format handlers

2. **Arguments**:
   - `--reset`: Clear existing handlers
   - `-p yes`: Make handlers persistent

3. **Privileged Mode**: Required to:
   - Access `/proc/sys/fs/binfmt_misc`
   - Register binary format handlers in the kernel

4. **Volume Mount**: 
   - Mounts host's `/proc/sys/fs/binfmt_misc`
   - Allows registration of format handlers

## Supported Architectures

The QEMU user-mode emulation supports multiple architectures:

- **x86_64** (AMD64): Most common Linux architecture
- **i386**: 32-bit x86
- **ARM** (various versions): ARMv6, ARMv7
- **MIPS**: Both big and little endian
- **PowerPC**: ppc, ppc64
- **RISC-V**: riscv32, riscv64
- **s390x**: IBM System z

## When Is This Needed?

This is necessary when:

- Running containers built for different architectures
- Using images without multi-arch manifest support
- Testing cross-architecture compatibility
- Migrating workloads from x86_64 to ARM64

### Examples

**Scenario 1**: Running AMD64-only images on ARM64 OCI instances
```bash
# Without QEMU: This would fail
kubectl run test --image=nginx:latest-amd64

# With QEMU: This works transparently
kubectl run test --image=nginx:latest-amd64
```

**Scenario 2**: Multi-arch images automatically use native architecture
```bash
# Will use ARM64 variant if available, otherwise emulate
kubectl run test --image=nginx:latest
```

## Deployment

### Automatic Deployment

This is deployed automatically by FluxCD as part of the cluster setup. No manual intervention needed.

### Manual Deployment (if needed)

```bash
# Apply directly
kubectl apply -k qemu/

# Or using kustomize
kustomize build qemu/ | kubectl apply -f -
```

### Verify Deployment

```bash
# Check DaemonSet status
kubectl get daemonset qemu-binfmt -n kube-system

# Verify pods are running on all nodes
kubectl get pods -n kube-system -l app=qemu-binfmt -o wide

# Check logs
kubectl logs -n kube-system -l app=qemu-binfmt
```

### Verify Binary Format Registration

SSH into a node and check:

```bash
# List registered formats
ls -l /proc/sys/fs/binfmt_misc/

# Check specific format (e.g., x86_64)
cat /proc/sys/fs/binfmt_misc/qemu-x86_64

# Expected output includes:
# enabled
# interpreter /usr/bin/qemu-x86_64-static
# flags: F
```

## Performance Considerations

### Overhead

- **Native execution**: Full speed (ARM64 on ARM64)
- **Emulated execution**: ~2-10x slower (AMD64 on ARM64)
- Performance impact varies by workload:
  - CPU-intensive: Higher overhead
  - I/O-intensive: Lower overhead

### Best Practices

1. **Prefer Native Images**: Use ARM64-native images when available
   ```bash
   # Check available architectures
   docker manifest inspect nginx:latest
   ```

2. **Multi-Arch Manifests**: Use images with multi-arch support
   - Automatically selects correct architecture
   - No emulation needed

3. **Build ARM64 Images**: Consider building ARM64 variants
   ```dockerfile
   # Dockerfile supports multi-arch builds
   FROM --platform=$BUILDPLATFORM golang:1.21 AS builder
   ARG TARGETPLATFORM
   ARG BUILDPLATFORM
   # ... build steps
   ```

4. **Monitor Performance**: Track CPU usage for emulated containers
   ```bash
   kubectl top pods -n <namespace>
   ```

## Troubleshooting

### DaemonSet Not Running

```bash
# Check DaemonSet status
kubectl describe daemonset qemu-binfmt -n kube-system

# Check pod status
kubectl get pods -n kube-system -l app=qemu-binfmt

# View logs
kubectl logs -n kube-system -l app=qemu-binfmt
```

### Containers Failing to Start

If AMD64 containers fail with "exec format error":

1. **Verify QEMU is running**:
   ```bash
   kubectl get pods -n kube-system -l app=qemu-binfmt
   ```

2. **Check registration**:
   ```bash
   # On the node
   cat /proc/sys/fs/binfmt_misc/qemu-x86_64
   ```

3. **Restart DaemonSet**:
   ```bash
   kubectl rollout restart daemonset qemu-binfmt -n kube-system
   ```

### Permission Errors

The DaemonSet requires privileged mode. If you see permission errors:

- Verify `securityContext.privileged: true` is set
- Check if PodSecurityPolicies/PodSecurityStandards are blocking privileged pods
- Ensure proper RBAC permissions

### Binary Format Not Registered

If formats aren't registered after deployment:

1. **Check if binfmt_misc is mounted**:
   ```bash
   mount | grep binfmt_misc
   ```

2. **Manually register** (temporary):
   ```bash
   docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
   ```

## Security Considerations

### Privileged Containers

The QEMU DaemonSet runs in privileged mode, which:

- ✅ **Pros**: Necessary for kernel integration
- ⚠️ **Cons**: Has elevated permissions

**Mitigations**:
- Runs in `kube-system` namespace (restricted access)
- Uses trusted `multiarch/qemu-user-static` image
- Only performs binary format registration
- No network access needed

### Container Image Trust

- Use official `multiarch/qemu-user-static` image
- Verify image signatures when possible
- Pin specific image tags for consistency

## Alternatives

### Native ARM64 Images

The best alternative is using native ARM64 images:

**Pros**:
- Full performance (no emulation)
- No security concerns
- Simpler setup

**Cons**:
- Not all images have ARM64 variants
- May require custom builds

### Multi-Arch Builds

Build images for multiple architectures:

```bash
# Build multi-arch image
docker buildx build --platform linux/amd64,linux/arm64 -t myimage:latest .
```

### Node Affinity

Run AMD64 workloads on AMD64 nodes (if available):

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
```

## Additional Resources

- [QEMU User Mode Documentation](https://www.qemu.org/docs/master/user/main.html)
- [binfmt_misc Documentation](https://docs.kernel.org/admin-guide/binfmt-misc.html)
- [multiarch/qemu-user-static GitHub](https://github.com/multiarch/qemu-user-static)
- [Docker Multi-Architecture Builds](https://docs.docker.com/build/building/multi-platform/)

## FAQ

**Q: Do I need this if all my images are ARM64?**
A: No, you only need QEMU for running non-ARM64 images.

**Q: Will this slow down my ARM64 containers?**
A: No, native ARM64 containers run at full speed. Only emulated containers have overhead.

**Q: Can I disable QEMU for specific workloads?**
A: QEMU doesn't activate unless needed. ARM64 images run natively even with QEMU present.

**Q: Is this production-ready?**
A: Yes, QEMU user-mode emulation is stable and widely used in production environments.

**Q: How much overhead does emulation add?**
A: Typically 2-10x slower for CPU-bound tasks. Exact overhead depends on the workload.
