#!/bin/bash

# Update manifests repository script
# This script updates the deployment image tag in the manifests repository

set -e

BUILD_NUMBER=${1:-$(date +%s)}
IMAGE_TAG=${2:-"latest"}
DOCKER_REGISTRY=${3:-"omarzaki222"}
IMAGE_NAME=${4:-"end-to-end-project"}
ENVIRONMENT=${5:-"dev"}
GITHUB_TOKEN=${6:-""}

# Create build-specific tag if not provided
if [ "$IMAGE_TAG" = "latest" ]; then
    GIT_COMMIT_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    IMAGE_TAG="${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
fi

echo "Updating manifests repository with image tag: ${IMAGE_TAG}"

# Check if GitHub token is provided
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GitHub token is required to push to manifests repository"
    echo "Please set GITHUB_TOKEN environment variable or pass it as parameter"
    exit 1
fi

# Clone the manifests repository with authentication
echo "Cloning manifests repository..."
git clone https://${GITHUB_TOKEN}@github.com/omarzaki222/EndtoEnd-Project-Manifests.git manifests-repo
cd manifests-repo

# Check if mainfest directory exists
if [ ! -d "mainfest" ]; then
    echo "❌ Error: mainfest directory not found!"
    exit 1
fi

# Navigate to mainfest directory and update image tag in deployment
echo "Updating image tag in deployment.yaml..."
cd mainfest

# Check if deployment.yaml exists
if [ ! -f "deployment.yaml" ]; then
    echo "❌ Error: deployment.yaml not found in mainfest directory!"
    exit 1
fi

# Backup the original file
cp deployment.yaml deployment.yaml.backup

# Update the image tag
sed -i "s|image: omarzaki222/end-to-end-project:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml

# Verify the change was made
echo "Updated deployment.yaml:"
grep "image:" deployment.yaml

# Check if there are any changes
if git diff --quiet deployment.yaml; then
    echo "No changes detected in deployment.yaml"
    cd ../..
    rm -rf manifests-repo
    exit 0
fi

# Go back to root and commit changes
cd ..
git config user.email "jenkins@example.com"
git config user.name "Jenkins"
git add mainfest/deployment.yaml
git commit -m "Update image tag to ${IMAGE_TAG} for ${ENVIRONMENT} environment (Build #${BUILD_NUMBER})"

# Push changes
echo "Pushing changes to manifests repository..."
git push origin main

echo "✅ Successfully updated manifests repository with image tag: ${IMAGE_TAG}"

# Clean up
cd ..
rm -rf manifests-repo

echo "Manifests update completed successfully!"