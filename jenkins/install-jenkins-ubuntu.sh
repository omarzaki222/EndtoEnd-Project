#!/bin/bash

# Install Jenkins directly on Ubuntu machine
# This script installs Jenkins as a service on workernode2

set -e

echo "🚀 Installing Jenkins on Ubuntu (workernode2)"
echo "============================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update

# Install required packages
echo "📦 Installing required packages..."
sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Jenkins repository key
echo "🔑 Adding Jenkins repository key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo "📋 Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
echo "🔄 Updating package list..."
sudo apt update

# Install Jenkins
echo "📦 Installing Jenkins..."
sudo apt install -y jenkins

# Start and enable Jenkins
echo "🚀 Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
echo "📊 Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

# Get Jenkins initial admin password
echo "🔐 Getting Jenkins initial admin password..."
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password not found yet")

# Get machine IP
MACHINE_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "🎉 Jenkins installation completed!"
echo "================================="
echo ""
echo "📋 Access Information:"
echo "  URL: http://${MACHINE_IP}:8080"
echo "  Initial Admin Password: ${JENKINS_PASSWORD}"
echo ""
echo "📋 Next Steps:"
echo "1. Open browser and go to: http://${MACHINE_IP}:8080"
echo "2. Enter the initial admin password: ${JENKINS_PASSWORD}"
echo "3. Install suggested plugins"
echo "4. Create admin user"
echo "5. Configure Jenkins"
echo ""
echo "🔧 Jenkins Configuration:"
echo "  - Jenkins will run as a service"
echo "  - Docker and kubectl are already available"
echo "  - Jenkins user will be added to docker group"
echo ""

# Add jenkins user to docker group
echo "🐳 Adding jenkins user to docker group..."
sudo usermod -aG docker jenkins

# Create jenkins workspace directory
echo "📁 Creating Jenkins workspace directory..."
sudo mkdir -p /var/lib/jenkins/workspace
sudo chown jenkins:jenkins /var/lib/jenkins/workspace

echo "✅ Jenkins setup completed!"
echo ""
echo "🌐 Access Jenkins at: http://${MACHINE_IP}:8080"
echo "🔑 Initial password: ${JENKINS_PASSWORD}"
