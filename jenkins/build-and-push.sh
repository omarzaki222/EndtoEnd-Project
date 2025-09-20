#!/bin/bash

# Docker build and push script for Jenkins pipeline
# Usage: ./build-and-push.sh [image_tag] [build_number]

set -e

# Load environment variables if available
if [ -f "env.local" ]; then
    source env.local
fi

IMAGE_TAG=${1:-latest}
BUILD_NUMBER=${2:-$(date +%s)}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"omarzaki222"}
IMAGE_NAME="end-to-end-project"

# Create build-specific tag if not provided
if [ "$IMAGE_TAG" = "latest" ]; then
    GIT_COMMIT_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    IMAGE_TAG="${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
fi

echo "Building Docker image..."
echo "Registry: $DOCKER_REGISTRY"
echo "Image: $IMAGE_NAME"
echo "Tag: $IMAGE_TAG"

# Build Docker image
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .

# Tag as latest and build-specific
docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}

echo "Docker image built successfully!"

# Login to Docker Hub (credentials should be set in Jenkins or environment)
echo "Logging in to Docker Hub..."
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
else
    echo "Docker credentials not found in environment variables"
    echo "Please set DOCKER_USERNAME and DOCKER_PASSWORD or use Jenkins credentials"
    exit 1
fi

# Push images
echo "Pushing images to registry..."
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}

echo "Images pushed successfully!"

# Logout
docker logout

echo "Build and push completed!"

# Optional: Update manifests repository
if [ "$3" = "update-manifests" ]; then
    echo "Updating manifests repository..."
    
    # Clone manifests repository
    git clone https://github.com/omarzaki222/EndtoEnd-Project-Manifests.git manifests-repo
    cd manifests-repo
    
    # Update image tag in deployment
    cd mainfest
    sed -i "s|image: omarzaki222/end-to-end-project:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml
    
    # Commit and push
    cd ..
    git config user.email "jenkins@example.com"
    git config user.name "Jenkins"
    git add mainfest/deployment.yaml
    git commit -m "Update image tag to ${IMAGE_TAG} (Build #${BUILD_NUMBER})" || echo "No changes to commit"
    git push origin main
    
    # Clean up
    cd ..
    rm -rf manifests-repo
    
    echo "Manifests repository updated successfully!"
fi
