#!/bin/bash

# Environment Setup Script
# This script helps you set up environment variables securely

echo "🔐 Environment Variables Setup"
echo "=============================="

echo ""
echo "This script will help you set up environment variables for your project."
echo ""

# Check if env.local already exists
if [ -f "env.local" ]; then
    echo "⚠️  env.local file already exists!"
    read -p "Do you want to overwrite it? (y/n): " OVERWRITE
    if [[ $OVERWRITE != "y" && $OVERWRITE != "Y" ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

echo "Please provide the following information:"
echo ""

# Docker Hub credentials
read -p "Docker Hub Username: " DOCKER_USERNAME
read -s -p "Docker Hub Password: " DOCKER_PASSWORD
echo ""

# GitHub credentials (optional)
read -p "GitHub Username (optional): " GITHUB_USERNAME
read -s -p "GitHub Token (optional): " GITHUB_TOKEN
echo ""

# Jenkins configuration
read -p "Jenkins URL (default: http://localhost:8080): " JENKINS_URL
JENKINS_URL=${JENKINS_URL:-http://localhost:8080}

read -p "Jenkins Username (default: admin): " JENKINS_USERNAME
JENKINS_USERNAME=${JENKINS_USERNAME:-admin}

read -s -p "Jenkins Token (optional): " JENKINS_TOKEN
echo ""

# Create env.local file
cat > env.local << EOF
# Environment Variables - DO NOT COMMIT THIS FILE
# This file contains sensitive information

# Docker Hub Configuration
DOCKER_USERNAME=$DOCKER_USERNAME
DOCKER_PASSWORD=$DOCKER_PASSWORD
DOCKER_REGISTRY=$DOCKER_USERNAME

# Application Configuration
APP_ENV=production
LOG_LEVEL=INFO
FLASK_ENV=production

# Kubernetes Configuration
KUBECONFIG_PATH=/home/workernode2/.kube/config

# GitHub Configuration
GITHUB_USERNAME=$GITHUB_USERNAME
GITHUB_TOKEN=$GITHUB_TOKEN

# Jenkins Configuration
JENKINS_URL=$JENKINS_URL
JENKINS_USERNAME=$JENKINS_USERNAME
JENKINS_TOKEN=$JENKINS_TOKEN
EOF

echo ""
echo "✅ Environment file created: env.local"
echo ""
echo "🔒 Security Notes:"
echo "- The env.local file is gitignored and will not be committed"
echo "- Never share this file or commit it to version control"
echo "- Use Jenkins credentials store for production environments"
echo ""
echo "📋 Next Steps:"
echo "1. Verify the env.local file contains correct information"
echo "2. Set up Jenkins credentials using the setup-credentials.sh script"
echo "3. Test your Docker build with: ./jenkins/build-and-push.sh test"
echo ""
