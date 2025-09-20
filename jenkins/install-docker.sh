#!/bin/bash

# Docker Installation Script for Jenkins
# This script installs Docker on the Jenkins server

set -e

echo "🐳 Installing Docker on Jenkins Server"
echo "====================================="

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root or with sudo"
    echo "Usage: sudo ./install-docker.sh"
    exit 1
fi

# Update package index
echo "📦 Updating package index..."
apt-get update

# Install required packages
echo "📦 Installing required packages..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "🔑 Adding Docker's official GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo "📋 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "📦 Updating package index with Docker repository..."
apt-get update

# Install Docker Engine
echo "🐳 Installing Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
echo "🚀 Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add jenkins user to docker group
echo "👤 Adding jenkins user to docker group..."
usermod -aG docker jenkins

# Verify installation
echo "✅ Verifying Docker installation..."
docker --version
docker run hello-world

echo ""
echo "🎉 Docker installation completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Restart Jenkins service: sudo systemctl restart jenkins"
echo "2. Verify Jenkins can access Docker: sudo -u jenkins docker --version"
echo "3. Test Jenkins pipeline with Docker build"
echo ""
echo "⚠️  Note: Jenkins service restart is required for the docker group changes to take effect"
