#!/bin/bash

# Kaniko build script for Jenkins
# This script creates and manages Kaniko build pods

set -e

BUILD_NUMBER=${1:-$(date +%s)}
IMAGE_TAG=${2:-"latest"}
DOCKER_REGISTRY=${3:-"omarzaki222"}
IMAGE_NAME=${4:-"end-to-end-project"}
WORKSPACE_PATH=${5:-"/var/jenkins_home/workspace/end-to-end-Project"}

# Create build-specific tag if not provided
if [ "$IMAGE_TAG" = "latest" ]; then
    GIT_COMMIT_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    IMAGE_TAG="${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
fi

echo "Building Docker image with Kaniko: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

# Create Kaniko build YAML
cat > kaniko-build.yaml << EOF
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
      path: ${WORKSPACE_PATH}
EOF

# Apply the Kaniko build pod
kubectl apply -f kaniko-build.yaml

# Wait for the pod to complete
echo "Waiting for Kaniko build to complete..."
kubectl wait --for=condition=Ready pod/kaniko-build-${BUILD_NUMBER} -n jenkins --timeout=600s || echo "Pod not ready, checking logs"

# Get pod logs
echo "Kaniko build logs:"
kubectl logs kaniko-build-${BUILD_NUMBER} -n jenkins

# Check if build was successful
if kubectl get pod kaniko-build-${BUILD_NUMBER} -n jenkins -o jsonpath='{.status.phase}' | grep -q "Succeeded"; then
    echo "✅ Kaniko build completed successfully!"
    echo "Images pushed:"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
else
    echo "❌ Kaniko build failed!"
    kubectl describe pod kaniko-build-${BUILD_NUMBER} -n jenkins
    exit 1
fi

# Clean up the pod
kubectl delete pod kaniko-build-${BUILD_NUMBER} -n jenkins
rm -f kaniko-build.yaml

echo "Build completed successfully!"
