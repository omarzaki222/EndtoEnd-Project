#!/bin/bash

# Jenkins Credentials Setup Script
# This script helps you set up the required credentials in Jenkins

echo "🔐 Jenkins Credentials Setup"
echo "============================"

echo ""
echo "📋 Required Credentials for Jenkins:"
echo ""

echo "1. Docker Hub Credentials"
echo "   - ID: docker-hub-credentials"
echo "   - Username: [Your Docker Hub username]"
echo "   - Password: [Your Docker Hub password]"
echo "   - Type: Username with password"
echo ""

echo "2. Kubernetes Configuration"
echo "   - ID: kubeconfig"
echo "   - Type: Secret file"
echo "   - File: Upload your kubeconfig file"
echo ""

echo "3. GitHub Credentials (Optional)"
echo "   - ID: github-credentials"
echo "   - Username: [Your GitHub username]"
echo "   - Password: [Your GitHub personal access token]"
echo "   - Type: Username with password"
echo ""

echo "🔧 Setup Instructions:"
echo "1. Go to Jenkins → Manage Jenkins → Manage Credentials"
echo "2. Select 'System' → 'Global credentials'"
echo "3. Click 'Add Credentials'"
echo "4. Configure each credential as shown above"
echo ""

echo "⚠️  Security Note:"
echo "Never commit credentials to version control."
echo "Use Jenkins credentials store or environment variables."
echo "The env.local file contains your credentials and is gitignored."
echo ""

echo "✅ After setting up credentials, you can:"
echo "1. Create a new Pipeline job in Jenkins"
echo "2. Use the Jenkinsfile from this repository"
echo "3. Run your first build"
echo ""

read -p "Press Enter to continue..."
