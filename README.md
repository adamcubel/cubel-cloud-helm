# Cubel Cloud Helm Chart

A Helm chart for deploying a cloud application with PostgreSQL database, OIDC authentication, and application management.

## Features

- **PostgreSQL Database**: Deployed as a dependency with persistence enabled
- **Database Configuration**: JSON-based database configuration with secure secret injection
- **OIDC Authentication**: Support for OpenID Connect with Keycloak or other providers
- **Applications Management**: Configurable application catalog
- **Secrets Management**: Support for existing Kubernetes secrets
- **Multi-port Support**: Exposes ports 80 and 3001

## Installation

### Add the Helm repository

```bash
helm repo add cubel-cloud https://<your-github-username>.github.io/cubel-cloud-helm
helm repo update
```

### Install the chart

```bash
helm install cubelcloud cubel-cloud/cubelcloud --namespace production --create-namespace
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Configuration

### Required Secrets (if using existing secrets)

**PostgreSQL Secret:**

```bash
kubectl create secret generic my-postgres-secret \
  --from-literal=postgres-password=adminpass \
  --from-literal=password=userpass
```

**OIDC Secret:**

```bash
kubectl create secret generic my-oidc-secret \
  --from-literal=client-secret=your-oidc-client-secret
```

**Gravatar API Secret:**

```bash
kubectl create secret generic my-gravatar-secret \
  --from-literal=api-key=your-gravatar-api-key
```

### Key Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Application image repository | `nginx` |
| `image.tag` | Application image tag | `latest` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Primary service port | `80` |
| `service.additionalPort` | Additional service port | `3001` |
| `database.name` | Database name | `cubel_cloud` |
| `database.port` | Database port | `5432` |
| `postgresql.enabled` | Enable PostgreSQL deployment | `true` |
| `postgresql.auth.username` | PostgreSQL username | `cubel_user` |
| `postgresql.auth.password` | PostgreSQL password | `changeme` |
| `postgresql.auth.existingSecret` | Use existing secret for PostgreSQL | `""` |
| `postgresql.primary.persistence.enabled` | Enable persistence | `true` |
| `postgresql.primary.persistence.size` | PVC size | `8Gi` |
| `secrets.oidc.enabled` | Enable OIDC authentication | `false` |
| `secrets.oidc.secretName` | OIDC secret name | `""` |
| `secrets.gravatar.enabled` | Enable Gravatar API | `false` |
| `secrets.gravatar.secretName` | Gravatar secret name | `""` |
| `oidc.issuer` | OIDC issuer URL | `https://your-keycloak-domain/realms/your-realm` |
| `oidc.clientId` | OIDC client ID | `your-client-id` |
| `applications` | List of applications | See values.yaml |

### Example Installation with Custom Values

```bash
helm install cubelcloud cubel-cloud/cubelcloud \
  --namespace production \
  --create-namespace \
  --set postgresql.auth.existingSecret=my-postgres-secret \
  --set secrets.oidc.enabled=true \
  --set secrets.oidc.secretName=my-oidc-secret \
  --set oidc.issuer=https://keycloak.example.com/realms/myrealm \
  --set oidc.clientId=my-client-id \
  --set image.repository=myregistry/cubelcloud \
  --set image.tag=v1.0.0
```

### Using a Custom Values File

Create `custom-values.yaml`:

```yaml
image:
  repository: myregistry/cubelcloud
  tag: v1.0.0

postgresql:
  auth:
    existingSecret: my-postgres-secret

secrets:
  oidc:
    enabled: true
    secretName: my-oidc-secret
  gravatar:
    enabled: true
    secretName: my-gravatar-secret

oidc:
  issuer: https://keycloak.example.com/realms/production
  clientId: cubelcloud-client
  redirectUri: https://cubelcloud.example.com/auth/callback

applications:
  - id: kubernetes
    name: Kubernetes Dashboard
    description: Kubernetes management interface
    icon: assets/k8s.svg
    url: https://kubernetes.example.com
  - id: grafana
    name: Grafana
    description: Monitoring and analytics
    icon: assets/grafana.svg
    url: https://grafana.example.com
```

Install:

```bash
helm install cubelcloud cubel-cloud/cubelcloud -f custom-values.yaml --namespace production --create-namespace
```

## Configuration Files

The chart creates the following configuration files in the container at `/app/config/`:

- **database.json**: Database connection configuration
- **oidc.json**: OIDC authentication configuration (if enabled)
- **applications.json**: Application catalog configuration
- **gravatar-api-key**: Gravatar API key file (if enabled)

## Upgrade

```bash
helm upgrade cubelcloud cubel-cloud/cubelcloud --namespace production
```

## Uninstall

```bash
helm uninstall cubelcloud --namespace production
```

## Development

### Local Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/cubel-cloud-helm.git
cd cubel-cloud-helm

# Set up pre-commit hooks (recommended)
./scripts/setup-precommit.sh

# Update dependencies
helm dependency update

# Install locally
helm install cubelcloud . --namespace development --create-namespace
```

### Pre-commit Hooks

This repository uses pre-commit hooks to ensure code quality and prevent common mistakes.

**Setup:**

```bash
# Run the setup script
./scripts/setup-precommit.sh

# Or manually
pip install pre-commit
pre-commit install
```

**Pre-commit checks include:**

- ✅ YAML syntax validation
- ✅ Helm chart linting
- ✅ Helm template rendering test
- ✅ Chart version validation (semver format)
- ✅ Secret detection
- ✅ Markdown linting
- ✅ Trailing whitespace removal
- ✅ Prevent commits directly to main branch

**Running manually:**

```bash
# Run on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run

# Skip hooks (not recommended)
git commit --no-verify
```

### Testing

```bash
# Dry-run to preview
helm install cubelcloud . --dry-run --debug

# Template rendering
helm template cubelcloud . > output.yaml

# Lint the chart
helm lint .
```

## GitHub Actions Workflows

This repository includes two automated workflows:

### 1. Pull Request Build (`pr-build.yml`)

**Triggers:** On pull requests to `main`

**Actions:**

- ✅ Builds and lints the Helm chart
- ✅ Tests template rendering
- ✅ Determines next version based on PR title
- ✅ Posts a comment on the PR with build status and next version
- ❌ Does NOT publish the chart

**Version Bumping:**
Add one of these tags to your PR title to specify the version bump:

- `[major]` - Breaking changes (1.0.0 → 2.0.0)
- `[minor]` - New features (1.0.0 → 1.1.0)
- `[patch]` - Bug fixes (1.0.0 → 1.0.1)

**Example PR titles:**

```
[minor] Add OIDC authentication support
[patch] Fix database connection string
[major] Redesign configuration structure
```

### 2. Release to GitHub Pages (`release.yml`)

**Triggers:** When PR is merged to `main`

**Actions:**

- ✅ Reads version bump from the merged PR title
- ✅ Updates `Chart.yaml` with new version
- ✅ Creates a Git tag (e.g., `v1.2.3`)
- ✅ Packages the Helm chart
- ✅ Creates a GitHub Release
- ✅ Publishes to GitHub Pages

### Setup GitHub Pages

1. Go to your repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Save - the workflow will automatically publish the chart on the next merge to main

### Workflow Example

```bash
# 1. Create a feature branch
git checkout -b feature/add-oidc

# 2. Make your changes
# ... edit files ...

# 3. Commit and push
git add .
git commit -m "Add OIDC support"
git push origin feature/add-oidc

# 4. Create a PR with version tag in title
# Title: "[minor] Add OIDC authentication support"
# The pr-build workflow will run and comment on the PR

# 5. Merge the PR
# The release workflow will automatically:
# - Bump version from 0.1.0 to 0.2.0
# - Create tag v0.2.0
# - Publish to GitHub Pages
```

### Manual Release (if needed)

If you need to manually trigger a release:

```bash
# Update Chart.yaml version manually
# Then commit and push to main
git add Chart.yaml
git commit -m "chore: bump version to 1.0.0"
git push origin main
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License
