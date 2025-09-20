#!/bin/bash

# Setup Jenkins Server on Kubernetes
# This script deploys Jenkins server and sets up initial configuration

set -e

echo "🚀 Setting up Jenkins Server on Kubernetes"
echo "=========================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not available"
    exit 1
fi

# Check if we can connect to Kubernetes
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"

# Deploy Jenkins
echo "📦 Deploying Jenkins server..."
kubectl apply -f deploy-jenkins-server.yaml

# Wait for Jenkins to be ready
echo "⏳ Waiting for Jenkins to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/jenkins -n jenkins

# Get Jenkins service info
echo "🔍 Getting Jenkins service information..."
kubectl get svc jenkins-service -n jenkins

# Get the NodePort
NODEPORT=$(kubectl get svc jenkins-service -n jenkins -o jsonpath='{.spec.ports[0].nodePort}')
echo "Jenkins will be available at: http://workernode1:${NODEPORT}"

# Get Jenkins admin password
echo "🔑 Getting Jenkins admin password..."
kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not available yet, Jenkins may still be starting"

echo ""
echo "🎉 Jenkins Server Setup Complete!"
echo "================================="
echo ""
echo "📋 Next Steps:"
echo "1. Access Jenkins at: http://workernode1:${NODEPORT}"
echo "2. Get admin password: kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword"
echo "3. Complete Jenkins setup wizard"
echo "4. Install recommended plugins"
echo "5. Create admin user"
echo ""
echo "🔧 After Jenkins is set up:"
echo "1. Create the workernode2 agent node"
echo "2. Update the Jenkinsfile to use the agent"
echo "3. Test the complete CI/CD pipeline"
echo ""
echo "📊 To check Jenkins status:"
echo "kubectl get pods -n jenkins"
echo "kubectl logs -f deployment/jenkins -n jenkins"
