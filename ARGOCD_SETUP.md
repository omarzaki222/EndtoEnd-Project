# ArgoCD GitOps Setup Guide

This guide explains how to set up ArgoCD for GitOps-based continuous deployment of your End-to-End Python Flask Application.

## 🎯 What is GitOps?

GitOps is a methodology that uses Git as the single source of truth for declarative infrastructure and applications. With ArgoCD, your Git repository becomes the control plane for your deployments.

## 🏗️ GitOps Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│   ArgoCD        │───▶│  Kubernetes     │
│   (Source of    │    │   (GitOps       │    │  (Target        │
│    Truth)       │    │    Controller)  │    │   Environment)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    Git Changes            Auto Sync              Live Deployment
    (Manifests)           (Detect & Apply)        (Desired State)
```

## 📁 ArgoCD Configuration Files

### Application Configurations

#### Development Environment (`argocd/application-dev.yaml`)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: end-to-end-app-dev
  namespace: argocd
  labels:
    app: end-to-end-app
    environment: dev
    project: default
spec:
  project: default
  source:
    repoURL: https://github.com/omarzaki222/EndtoEnd-Project.git
    targetRevision: HEAD
    path: mainfest
    kustomize:
      commonLabels:
        environment: dev
      images:
        - name: omarzaki222/end-to-end-project
          newTag: latest
  destination:
    server: https://kubernetes.default.svc
    namespace: flask-app-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  revisionHistoryLimit: 10
```

#### Staging Environment (`argocd/application-staging.yaml`)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: end-to-end-app-staging
  namespace: argocd
  labels:
    app: end-to-end-app
    environment: staging
    project: default
spec:
  project: default
  source:
    repoURL: https://github.com/omarzaki222/EndtoEnd-Project.git
    targetRevision: HEAD
    path: mainfest
    kustomize:
      commonLabels:
        environment: staging
      images:
        - name: omarzaki222/end-to-end-project
          newTag: staging
  destination:
    server: https://kubernetes.default.svc
    namespace: flask-app-staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  revisionHistoryLimit: 10
```

#### Production Environment (`argocd/application-prod.yaml`)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: end-to-end-app-prod
  namespace: argocd
  labels:
    app: end-to-end-app
    environment: prod
    project: default
spec:
  project: default
  source:
    repoURL: https://github.com/omarzaki222/EndtoEnd-Project.git
    targetRevision: HEAD
    path: mainfest
    kustomize:
      commonLabels:
        environment: prod
      images:
        - name: omarzaki222/end-to-end-project
          newTag: prod
  destination:
    server: https://kubernetes.default.svc
    namespace: flask-app-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  revisionHistoryLimit: 10
```

## 🚀 Installation Steps

### 1. Install ArgoCD

```bash
# Run the installation script
cd /home/workernode2/pythonapp
./argocd/install-argocd.sh
```

### 2. Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access ArgoCD UI
# URL: https://localhost:8080
# Username: admin
# Password: (retrieved from installation script)
```

### 3. Create Applications

```bash
# Create all ArgoCD applications
./argocd/setup-applications.sh
```

## 🔄 GitOps Workflow

### Automatic Deployment Flow

1. **Code Push** → Developer pushes code to GitHub
2. **Jenkins Build** → Jenkins builds Docker image and pushes to registry
3. **Git Update** → Jenkins updates deployment manifests in Git
4. **ArgoCD Detection** → ArgoCD detects changes in Git repository
5. **Auto Sync** → ArgoCD automatically syncs changes to Kubernetes
6. **Deployment** → Application is deployed to target environment

### Manual Deployment Flow

1. **Git Changes** → Update manifests in Git repository
2. **ArgoCD UI** → Access ArgoCD UI to view changes
3. **Manual Sync** → Trigger manual sync if needed
4. **Deployment** → Application is deployed to target environment

## 🛠️ Configuration Details

### Sync Policies

#### Automated Sync
```yaml
syncPolicy:
  automated:
    prune: true      # Remove resources not in Git
    selfHeal: true   # Automatically fix drift
```

#### Sync Options
```yaml
syncOptions:
  - CreateNamespace=true                    # Create namespace if not exists
  - PrunePropagationPolicy=foreground      # Wait for deletion
  - PruneLast=true                         # Delete resources last
```

#### Retry Policy
```yaml
retry:
  limit: 5
  backoff:
    duration: 5s
    factor: 2
    maxDuration: 3m
```

### Kustomize Integration

ArgoCD uses Kustomize to customize manifests for different environments:

```yaml
kustomize:
  commonLabels:
    environment: dev
  images:
    - name: omarzaki222/end-to-end-project
      newTag: latest
```

## 📊 Monitoring and Management

### ArgoCD CLI

```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Login to ArgoCD
argocd login localhost:8080

# List applications
argocd app list

# Get application status
argocd app get end-to-end-app-dev

# Sync application
argocd app sync end-to-end-app-dev

# Get application logs
argocd app logs end-to-end-app-dev
```

### Kubernetes Commands

```bash
# List ArgoCD applications
kubectl get applications -n argocd

# Describe application
kubectl describe application end-to-end-app-dev -n argocd

# Get application events
kubectl get events -n argocd --field-selector involvedObject.name=end-to-end-app-dev

# Check sync status
kubectl get application end-to-end-app-dev -n argocd -o jsonpath='{.status.sync.status}'
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Application Not Syncing
```bash
# Check application status
kubectl describe application end-to-end-app-dev -n argocd

# Check for sync errors
kubectl get events -n argocd --field-selector involvedObject.name=end-to-end-app-dev

# Force sync
argocd app sync end-to-end-app-dev --force
```

#### 2. Repository Access Issues
```bash
# Check repository connectivity
argocd repo get https://github.com/omarzaki222/EndtoEnd-Project.git

# Test repository access
argocd repo get https://github.com/omarzaki222/EndtoEnd-Project.git --refresh
```

#### 3. Sync Failures
```bash
# Check sync logs
argocd app logs end-to-end-app-dev --follow

# Check application health
argocd app get end-to-end-app-dev --refresh
```

### Debug Commands

```bash
# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Check ArgoCD application controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# Check ArgoCD repo server logs
kubectl logs -n argocd deployment/argocd-repo-server
```

## 🔐 Security Considerations

### Repository Access

1. **Use SSH Keys** for private repositories
2. **Configure RBAC** for team access
3. **Use Service Accounts** for automated access
4. **Enable TLS** for ArgoCD server

### RBAC Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    g, admins, role:admin
```

## 📈 Best Practices

### 1. Repository Structure
- Keep manifests in dedicated directories
- Use Kustomize for environment-specific configurations
- Version control all configuration changes

### 2. Application Management
- Use descriptive application names
- Implement proper labeling and tagging
- Set appropriate sync policies

### 3. Security
- Use least privilege access
- Enable RBAC
- Regular security audits

### 4. Monitoring
- Set up alerts for sync failures
- Monitor application health
- Track deployment metrics

## 🚀 Advanced Features

### 1. Multi-Cluster Deployment
```yaml
destination:
  server: https://production-cluster.example.com
  namespace: flask-app-prod
```

### 2. Helm Integration
```yaml
source:
  repoURL: https://github.com/omarzaki222/EndtoEnd-Project.git
  path: helm-charts
  helm:
    valueFiles:
      - values-prod.yaml
```

### 3. Application Sets
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: end-to-end-apps
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
  template:
    metadata:
      name: '{{name}}-end-to-end-app'
    spec:
      project: default
      source:
        repoURL: https://github.com/omarzaki222/EndtoEnd-Project.git
        path: mainfest
      destination:
        server: '{{server}}'
        namespace: flask-app
```

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/)

---

This GitOps setup provides a robust, automated deployment pipeline that ensures your application deployments are consistent, traceable, and reliable across all environments.
