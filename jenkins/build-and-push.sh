#!/bin/bash

# Docker build and push script for Jenkins pipeline
# Usage: ./build-and-push.sh [image_tag]

set -e

# Load environment variables if available
if [ -f "env.local" ]; then
    source env.local
fi

IMAGE_TAG=${1:-latest}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"omarzaki222"}
IMAGE_NAME="end-to-end-project"

echo "Building Docker image..."
echo "Registry: $DOCKER_REGISTRY"
echo "Image: $IMAGE_NAME"
echo "Tag: $IMAGE_TAG"

# Build Docker image
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .

# Tag as latest
docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest

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

echo "Images pushed successfully!"

# Logout
docker logout

echo "Build and push completed!"
