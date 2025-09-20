#!/bin/bash

# Configure Docker Access for Jenkins in Kubernetes
# This script helps configure Docker access when Jenkins is running in Kubernetes

set -e

echo "🐳 Configuring Docker Access for Jenkins in Kubernetes"
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

# Find Jenkins deployment
JENKINS_DEPLOYMENT=$(kubectl get deployments -A | grep jenkins | awk '{print $1, $2}' | head -1)

if [ -n "$JENKINS_DEPLOYMENT" ]; then
    NAMESPACE=$(echo $JENKINS_DEPLOYMENT | awk '{print $1}')
    DEPLOYMENT_NAME=$(echo $JENKINS_DEPLOYMENT | awk '{print $2}')
    
    echo "🔍 Found Jenkins deployment: $DEPLOYMENT_NAME in namespace: $NAMESPACE"
    
    # Check current Jenkins pod configuration
    echo "📋 Current Jenkins pod configuration:"
    kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME -o wide
    
    # Check if Jenkins pod has Docker socket mounted
    echo ""
    echo "🔍 Checking Docker socket mount..."
    if kubectl describe pod -n $NAMESPACE -l app=$DEPLOYMENT_NAME | grep -q "/var/run/docker.sock"; then
        echo "✅ Docker socket is mounted in Jenkins pod"
    else
        echo "⚠️  Docker socket is not mounted in Jenkins pod"
        echo ""
        echo "📋 To fix this, you need to update your Jenkins deployment:"
        echo ""
        echo "1. Create a patch file for Jenkins deployment:"
        cat > jenkins-docker-patch.yaml << EOF
spec:
  template:
    spec:
      containers:
      - name: jenkins
        volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
      volumes:
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
EOF
        
        echo "2. Apply the patch:"
        echo "   kubectl patch deployment $DEPLOYMENT_NAME -n $NAMESPACE --patch-file jenkins-docker-patch.yaml"
        echo ""
        echo "3. Wait for rollout to complete:"
        echo "   kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE"
    fi
    
    # Check if Jenkins pod has Docker binary
    echo ""
    echo "🔍 Checking Docker binary availability..."
    JENKINS_POD=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME -o jsonpath='{.items[0].metadata.name}')
    
    if kubectl exec -n $NAMESPACE $JENKINS_POD -- which docker &> /dev/null; then
        echo "✅ Docker binary is available in Jenkins pod"
    else
        echo "⚠️  Docker binary is not available in Jenkins pod"
        echo ""
        echo "📋 To fix this, you can:"
        echo "1. Use a Jenkins image that includes Docker"
        echo "2. Install Docker inside the Jenkins container"
        echo "3. Use Docker-in-Docker (DinD) approach"
    fi
    
else
    echo "⚠️  No Jenkins deployment found in the cluster"
    echo "   Please check if Jenkins is properly deployed"
    echo ""
    echo "🔍 Available deployments:"
    kubectl get deployments -A | grep -i jenkins || echo "No Jenkins deployments found"
fi

echo ""
echo "🔧 Alternative Solutions for Kubernetes:"
echo ""
echo "1. **Docker-in-Docker (DinD)**: Use a Jenkins agent with Docker-in-Docker"
echo "2. **Kaniko**: Use Kaniko for building Docker images in Kubernetes"
echo "3. **Buildah**: Use Buildah for building container images"
echo "4. **Remote Docker Host**: Configure Jenkins to use a remote Docker host"
echo ""
echo "📚 For more details, see DOCKER_TROUBLESHOOTING.md"
