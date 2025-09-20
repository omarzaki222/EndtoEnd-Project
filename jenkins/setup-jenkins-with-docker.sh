#!/bin/bash

# Complete Jenkins Setup with Docker Support
# This script sets up Jenkins with Docker support

set -e

echo "🚀 Setting up Jenkins with Docker Support"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root or with sudo"
    echo "Usage: sudo ./setup-jenkins-with-docker.sh"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Run: sudo ./install-docker.sh"
    exit 1
fi

echo "✅ Docker is installed"

# Install Java (required for Jenkins)
echo "☕ Installing Java..."
apt-get update
apt-get install -y openjdk-11-jdk

# Add Jenkins repository
echo "📦 Adding Jenkins repository..."
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian binary/" > /etc/apt/sources.list.d/jenkins.list

# Update package index
apt-get update

# Install Jenkins
echo "🔧 Installing Jenkins..."
apt-get install -y jenkins

# Start and enable Jenkins service
echo "🚀 Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Add jenkins user to docker group
echo "👤 Adding jenkins user to docker group..."
usermod -aG docker jenkins

# Get Jenkins initial admin password
echo "🔑 Getting Jenkins initial admin password..."
sleep 10  # Wait for Jenkins to start
JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password not found")

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "🎉 Jenkins setup completed successfully!"
echo ""
echo "📋 Access Information:"
echo "  - Jenkins URL: http://$SERVER_IP:8080"
echo "  - Initial Admin Password: $JENKINS_PASSWORD"
echo ""
echo "🔧 Next Steps:"
echo "1. Open Jenkins in your browser: http://$SERVER_IP:8080"
echo "2. Enter the initial admin password: $JENKINS_PASSWORD"
echo "3. Install suggested plugins"
echo "4. Create an admin user"
echo "5. Configure your pipeline"
echo ""
echo "🐳 Docker Configuration:"
echo "  - Jenkins user has been added to docker group"
echo "  - Docker commands should work in Jenkins pipelines"
echo "  - Restart Jenkins if needed: sudo systemctl restart jenkins"
echo ""
echo "📚 For pipeline setup, see JENKINS_SETUP.md"
