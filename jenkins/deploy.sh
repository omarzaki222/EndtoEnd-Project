#!/bin/bash

# Deployment script for Jenkins pipeline
# Usage: ./deploy.sh [environment] [image_tag]

set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
NAMESPACE="flask-app-${ENVIRONMENT}"

echo "Deploying to environment: $ENVIRONMENT"
echo "Using image tag: $IMAGE_TAG"
echo "Namespace: $NAMESPACE"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "Cannot connect to Kubernetes cluster"
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Update image tag in deployment
if [ "$IMAGE_TAG" != "latest" ]; then
    sed -i "s|image: omarzaki222/end-to-end-project:.*|image: omarzaki222/end-to-end-project:${IMAGE_TAG}|g" mainfest/deployment.yaml
fi

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f mainfest/pv.yaml
kubectl apply -f mainfest/pvc.yaml
kubectl apply -f mainfest/deployment.yaml
kubectl apply -f mainfest/service.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/end-to-end-app -n $NAMESPACE --timeout=300s

# Verify deployment
echo "Verifying deployment..."
kubectl get pods -n $NAMESPACE -l app=end-to-end-app
kubectl get svc -n $NAMESPACE

# Health check
echo "Performing health check..."
sleep 30
POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app=end-to-end-app -o jsonpath='{.items[0].status.phase}')
if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ Deployment successful! Pod is running."
else
    echo "❌ Deployment failed! Pod status: $POD_STATUS"
    exit 1
fi

echo "Deployment completed successfully!"
