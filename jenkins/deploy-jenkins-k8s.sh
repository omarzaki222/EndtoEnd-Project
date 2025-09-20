#!/bin/bash

# Deploy Jenkins in Kubernetes with Docker Support
# This script deploys Jenkins in your Kubernetes cluster

set -e

echo "🚀 Deploying Jenkins in Kubernetes with Docker Support"
echo "====================================================="

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

echo "✅ Connected to Kubernetes cluster"

# Deploy Jenkins
echo "📦 Deploying Jenkins..."
kubectl apply -f jenkins-k8s-deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for Jenkins to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/jenkins -n jenkins

# Get Jenkins service details
echo "📋 Jenkins service details:"
kubectl get svc jenkins-service -n jenkins

# Get Jenkins pod details
echo "📋 Jenkins pod details:"
kubectl get pods -n jenkins -l app=jenkins

# Get Jenkins initial admin password
echo "🔑 Getting Jenkins initial admin password..."
sleep 30  # Wait for Jenkins to fully start
JENKINS_POD=$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')
JENKINS_PASSWORD=$(kubectl exec -n jenkins $JENKINS_POD -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not found")

# Get cluster IP
CLUSTER_IP=$(kubectl get svc jenkins-service -n jenkins -o jsonpath='{.spec.clusterIP}')
NODE_PORT=$(kubectl get svc jenkins-service -n jenkins -o jsonpath='{.spec.ports[0].nodePort}')

echo ""
echo "🎉 Jenkins deployed successfully!"
echo ""
echo "📋 Access Information:"
echo "  - Jenkins URL: http://<node-ip>:$NODE_PORT"
echo "  - Cluster IP: http://$CLUSTER_IP:8080"
echo "  - Initial Admin Password: $JENKINS_PASSWORD"
echo ""
echo "🔧 To access Jenkins:"
echo "1. Get node IP: kubectl get nodes -o wide"
echo "2. Open browser: http://<node-ip>:$NODE_PORT"
echo "3. Enter initial admin password: $JENKINS_PASSWORD"
echo ""
echo "🐳 Docker Configuration:"
echo "  - Docker socket is mounted in Jenkins pod"
echo "  - Jenkins has cluster admin permissions"
echo "  - Docker commands should work in Jenkins pipelines"
echo ""
echo "📚 Next Steps:"
echo "1. Access Jenkins UI and complete setup"
echo "2. Install required plugins (Docker Pipeline, Kubernetes CLI, etc.)"
echo "3. Configure your pipeline"
echo "4. Test Docker build in a pipeline"
echo ""
echo "🔍 Useful Commands:"
echo "  - Check Jenkins logs: kubectl logs -f deployment/jenkins -n jenkins"
echo "  - Port forward: kubectl port-forward svc/jenkins-service 8080:8080 -n jenkins"
echo "  - Get Jenkins pod: kubectl get pods -n jenkins -l app=jenkins"
