#!/bin/bash

# ArgoCD Installation Script
# This script installs ArgoCD on your Kubernetes cluster

set -e

echo "🚀 Installing ArgoCD on Kubernetes"
echo "=================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster connection verified"

# Create ArgoCD namespace
echo "📦 Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📥 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 ArgoCD installation completed!"
echo ""
echo "📋 Access Information:"
echo "  - ArgoCD Server: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  - Username: admin"
echo "  - Password: $ARGOCD_PASSWORD"
echo ""
echo "🌐 To access ArgoCD UI:"
echo "  1. Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  2. Open: https://localhost:8080"
echo "  3. Login with admin / $ARGOCD_PASSWORD"
echo ""
echo "📝 Next Steps:"
echo "  1. Access ArgoCD UI"
echo "  2. Create applications using the YAML files in argocd/ directory"
echo "  3. Configure Git repository access"
echo "  4. Set up automated sync policies"
echo ""
