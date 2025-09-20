#!/bin/bash

# Process Jenkins build script
# This script runs on the host system and handles Kaniko builds for Jenkins

set -e

JENKINS_WORKSPACE=${1:-"/var/jenkins_home/workspace/end-to-end-Project"}
BUILD_INFO_FILE="${JENKINS_WORKSPACE}/build-info.txt"

echo "🔍 Processing Jenkins build..."
echo "Jenkins workspace: ${JENKINS_WORKSPACE}"

# Check if build info file exists
if [ ! -f "$BUILD_INFO_FILE" ]; then
    echo "❌ Build info file not found: ${BUILD_INFO_FILE}"
    echo "Make sure Jenkins has run and created the build-info.txt file"
    exit 1
fi

# Read build parameters
source "$BUILD_INFO_FILE"

echo "📋 Build Parameters:"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  Image Tag: ${IMAGE_TAG}"
echo "  Full Image Name: ${FULL_IMAGE_NAME}"
echo "  Docker Registry: ${DOCKER_REGISTRY}"
echo "  Image Name: ${IMAGE_NAME}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not available on this system"
    exit 1
fi

# Check if we can connect to Kubernetes
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Create Kaniko build YAML
echo "📦 Creating Kaniko build pod..."
cat > kaniko-build-${BUILD_NUMBER}.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: kaniko-build-${BUILD_NUMBER}
  namespace: jenkins
spec:
  restartPolicy: Never
  containers:
  - name: kaniko-build
    image: gcr.io/kaniko-project/executor:latest
    args:
    - "--context=dir:///workspace"
    - "--dockerfile=/workspace/Dockerfile"
    - "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    - "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    - "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
    - "--cache=true"
    - "--cache-ttl=24h"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: build-context
      mountPath: /workspace
  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-secret
  - name: build-context
    hostPath:
      path: ${JENKINS_WORKSPACE}
EOF

# Apply the Kaniko build pod
echo "🚀 Starting Kaniko build..."
kubectl apply -f kaniko-build-${BUILD_NUMBER}.yaml

# Wait for the pod to complete
echo "⏳ Waiting for Kaniko build to complete..."
kubectl wait --for=condition=Ready pod/kaniko-build-${BUILD_NUMBER} -n jenkins --timeout=600s || echo "Pod not ready, checking logs"

# Get pod logs
echo "📋 Kaniko build logs:"
kubectl logs kaniko-build-${BUILD_NUMBER} -n jenkins

# Check if build was successful
if kubectl get pod kaniko-build-${BUILD_NUMBER} -n jenkins -o jsonpath='{.status.phase}' | grep -q "Succeeded"; then
    echo "✅ Kaniko build completed successfully!"
    echo "Images pushed:"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
    
    # Create success marker for Jenkins
    echo "SUCCESS" > "${JENKINS_WORKSPACE}/build-result.txt"
    echo "Build completed at: $(date)" >> "${JENKINS_WORKSPACE}/build-result.txt"
else
    echo "❌ Kaniko build failed!"
    kubectl describe pod kaniko-build-${BUILD_NUMBER} -n jenkins
    
    # Create failure marker for Jenkins
    echo "FAILED" > "${JENKINS_WORKSPACE}/build-result.txt"
    echo "Build failed at: $(date)" >> "${JENKINS_WORKSPACE}/build-result.txt"
    exit 1
fi

# Clean up the pod
kubectl delete pod kaniko-build-${BUILD_NUMBER} -n jenkins
rm -f kaniko-build-${BUILD_NUMBER}.yaml

echo "🎉 Build processing completed successfully!"
