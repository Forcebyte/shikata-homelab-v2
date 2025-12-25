# Contributing to Shikata Homelab v2

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a welcoming environment

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check existing issues to avoid duplicates
2. Create a new issue with a clear title and description
3. Include steps to reproduce (for bugs)
4. Add relevant labels

### Suggesting Enhancements

1. Open an issue describing the enhancement
2. Explain why it would be useful
3. Provide examples if possible

### Contributing Code

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes locally
5. Commit with clear messages: `git commit -m "Add feature: description"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a Pull Request

## Development Setup

### Prerequisites

- Git
- Terraform >= 1.0
- kubectl
- kustomize
- Access to a Kubernetes cluster (for testing)

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/shikata-homelab-v2.git
cd shikata-homelab-v2

# Install pre-commit hooks (optional but recommended)
# This will run linting before each commit
```

### Testing Changes Locally

#### For Kubernetes Manifests

```bash
# Validate kustomization
cd k8s/apps/your-app
kustomize build .

# Validate with kubeconform
kustomize build . | kubeconform -strict -
```

#### For Terraform

```bash
cd terraform/

# Format check
terraform fmt -check -recursive

# Initialize and validate
terraform init -backend=false
terraform validate

# Run TFLint
tflint --init
tflint
```

## Coding Standards

### Kubernetes Manifests

- Use clear, descriptive names for resources
- Include namespace in all resources
- Add comments for complex configurations
- Follow the existing structure in `k8s/apps/`
- Use kustomize for configuration management
- Set resource limits and requests where appropriate

Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-namespace
  annotations:
    description: "Brief description of what this does"
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
        image: my-image:tag
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

### Terraform

- Follow HashiCorp's style guide
- Use `terraform fmt` to format files
- Add descriptions to all variables
- Mark sensitive variables appropriately
- Group related resources in the same file
- Add comments for complex logic

Example:
```hcl
variable "example_var" {
  description = "Clear description of what this variable does"
  type        = string
  sensitive   = false
  default     = "default-value"
}

resource "kubernetes_secret" "example" {
  metadata {
    name      = "example-secret"
    namespace = "default"
  }

  data = {
    key = var.example_var
  }

  type = "Opaque"
}
```

### YAML Files

- Use 2 spaces for indentation
- Keep lines under 120 characters when possible
- Use consistent quoting (prefer double quotes)
- Comment complex sections

## Testing Guidelines

### Pre-Commit Checks

Before committing, ensure:

1. All YAML files are valid
2. Kustomize builds successfully
3. Terraform validates without errors
4. No secrets are committed

### Automated Tests

All pull requests must pass:

- Kubernetes manifest validation (kubeconform, kustomize)
- Terraform validation and formatting
- YAML linting
- Security scanning (Trivy)
- Secrets detection

### Manual Testing

For significant changes:

1. Deploy to a test cluster if possible
2. Verify the application starts correctly
3. Test basic functionality
4. Check logs for errors

## Pull Request Process

### Before Submitting

- [ ] Code follows the style guidelines
- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts with main branch

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Configuration change

## Testing
Describe how you tested these changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No secrets committed
```

### Review Process

1. Automated checks must pass
2. At least one maintainer review required
3. Address all review comments
4. Maintainer will merge once approved

### After Merge

- Delete your feature branch
- Pull the latest main branch
- Verify deployment in production (if applicable)

## Questions?

If you have questions about contributing:

1. Check existing documentation
2. Search closed issues
3. Open a discussion issue
4. Reach out to maintainers

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [FluxCD Documentation](https://fluxcd.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)

---

Thank you for contributing to Shikata Homelab v2!
