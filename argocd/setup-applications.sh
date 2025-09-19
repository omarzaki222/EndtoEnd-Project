#!/bin/bash

# ArgoCD Applications Setup Script
# This script creates ArgoCD applications for different environments

set -e

echo "🔧 Setting up ArgoCD Applications"
echo "================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if ArgoCD is running
if ! kubectl get deployment argocd-server -n argocd &> /dev/null; then
    echo "❌ ArgoCD is not installed. Please run ./install-argocd.sh first"
    exit 1
fi

echo "✅ ArgoCD is running"

# Create applications
echo "📦 Creating ArgoCD applications..."

# Development environment
echo "  - Creating development application..."
kubectl apply -f argocd/application-dev.yaml

# Staging environment
echo "  - Creating staging application..."
kubectl apply -f argocd/application-staging.yaml

# Production environment
echo "  - Creating production application..."
kubectl apply -f argocd/application-prod.yaml

echo ""
echo "🎉 ArgoCD applications created successfully!"
echo ""
echo "📋 Applications created:"
echo "  - end-to-end-app-dev (Development)"
echo "  - end-to-end-app-staging (Staging)"
echo "  - end-to-end-app-prod (Production)"
echo ""
echo "🌐 To view applications:"
echo "  1. Access ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  2. Open: https://localhost:8080"
echo "  3. Login and view your applications"
echo ""
echo "🔄 Applications will automatically sync with your Git repository"
echo "   Any changes pushed to the mainfest/ directory will trigger deployments"
echo ""
