#!/bin/bash
# Fix kubectl configuration for Jenkins user
# This script copies the kubeconfig to Jenkins user and sets proper permissions

set -e

echo "🔧 Fixing kubectl configuration for Jenkins user"
echo "================================================"

# Create .kube directory for Jenkins user
sudo mkdir -p /var/lib/jenkins/.kube

# Copy kubeconfig from current user to Jenkins user
sudo cp /home/workernode2/.kube/config /var/lib/jenkins/.kube/config

# Set proper ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

# Set proper permissions
sudo chmod 600 /var/lib/jenkins/.kube/config

echo "✅ kubectl configuration fixed for Jenkins user"

# Test kubectl access for Jenkins user
echo "🧪 Testing kubectl access for Jenkins user..."
sudo -u jenkins kubectl cluster-info

echo "🎉 kubectl is now properly configured for Jenkins!"
echo ""
echo "Your Jenkins pipeline should now be able to run health checks successfully!"
