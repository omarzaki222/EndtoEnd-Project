#!/bin/bash

# Patch Jenkins StatefulSet to add Docker support
# This script adds Docker socket and binary to your existing Jenkins deployment

set -e

echo "🐳 Patching Jenkins StatefulSet for Docker Support"
echo "================================================="

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

# Check if Jenkins StatefulSet exists
if ! kubectl get statefulset jenkins -n jenkins &> /dev/null; then
    echo "❌ Jenkins StatefulSet not found in jenkins namespace"
    exit 1
fi

echo "✅ Found Jenkins StatefulSet"

# Check if Docker is available on the nodes
echo "🔍 Checking Docker availability on nodes..."
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')
DOCKER_AVAILABLE=true

for node in $NODES; do
    if ! kubectl debug node/$node -it --image=busybox -- chroot /host which docker &> /dev/null; then
        echo "⚠️  Docker not found on node: $node"
        DOCKER_AVAILABLE=false
    else
        echo "✅ Docker found on node: $node"
    fi
done

if [ "$DOCKER_AVAILABLE" = false ]; then
    echo ""
    echo "⚠️  Docker is not available on all nodes"
    echo "   You may need to install Docker on your Kubernetes nodes"
    echo "   Or use alternative solutions like Kaniko or Buildah"
    echo ""
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [[ $CONTINUE != "y" && $CONTINUE != "Y" ]]; then
        echo "Aborting patch..."
        exit 1
    fi
fi

# Apply the patch
echo "📦 Applying Docker patch to Jenkins StatefulSet..."
kubectl patch statefulset jenkins -n jenkins --patch-file jenkins-docker-patch.yaml

# Wait for rollout to complete
echo "⏳ Waiting for Jenkins rollout to complete..."
kubectl rollout status statefulset/jenkins -n jenkins --timeout=300s

# Verify the patch
echo "🔍 Verifying Docker access in Jenkins pod..."
JENKINS_POD=$(kubectl get pods -n jenkins -l app.kubernetes.io/component=jenkins-controller -o jsonpath='{.items[0].metadata.name}')

# Wait a bit for the pod to be ready
sleep 30

# Check if Docker socket is mounted
if kubectl exec -n jenkins $JENKINS_POD -c jenkins -- ls -la /var/run/docker.sock &> /dev/null; then
    echo "✅ Docker socket is mounted in Jenkins pod"
else
    echo "❌ Docker socket is not mounted in Jenkins pod"
fi

# Check if Docker binary is available
if kubectl exec -n jenkins $JENKINS_POD -c jenkins -- which docker &> /dev/null; then
    echo "✅ Docker binary is available in Jenkins pod"
    
    # Test Docker command
    if kubectl exec -n jenkins $JENKINS_POD -c jenkins -- docker --version &> /dev/null; then
        echo "✅ Docker command works in Jenkins pod"
    else
        echo "⚠️  Docker command failed in Jenkins pod"
    fi
else
    echo "❌ Docker binary is not available in Jenkins pod"
fi

echo ""
echo "🎉 Jenkins Docker patch completed!"
echo ""
echo "📋 Next Steps:"
echo "1. Test your Jenkins pipeline with Docker build"
echo "2. If Docker is not working, consider using Kaniko or Buildah"
echo "3. Check Jenkins logs if there are issues: kubectl logs -f $JENKINS_POD -c jenkins -n jenkins"
echo ""
echo "🔧 Alternative Solutions:"
echo "1. **Kaniko**: Use Kaniko for building Docker images in Kubernetes"
echo "2. **Buildah**: Use Buildah for building container images"
echo "3. **Docker-in-Docker**: Use DinD approach with Jenkins agents"
