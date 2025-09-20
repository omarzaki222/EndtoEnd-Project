#!/bin/bash

# Setup GitHub credentials in Jenkins
# This script helps you add the GitHub token to Jenkins credentials

set -e

echo "🔑 Setting up GitHub Credentials in Jenkins"
echo "=========================================="

# Check if GitHub token is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <github_token>"
    echo "Example: $0 your_github_token_here"
    exit 1
fi

GITHUB_TOKEN=$1

echo "GitHub Token: ${GITHUB_TOKEN:0:10}..." # Show only first 10 characters for security

echo ""
echo "📋 Manual Steps to Add GitHub Credentials in Jenkins:"
echo "====================================================="
echo ""
echo "1. Open Jenkins Web UI"
echo "2. Go to: Manage Jenkins → Manage Credentials"
echo "3. Click on: (global) → Add Credentials"
echo "4. Fill in the form:"
echo "   - Kind: Secret text"
echo "   - Secret: ${GITHUB_TOKEN}"
echo "   - ID: github-token"
echo "   - Description: GitHub Personal Access Token for manifests repository"
echo "5. Click: OK"
echo ""
echo "🔧 Alternative: Using Jenkins CLI (if available)"
echo "==============================================="
echo ""
echo "If you have Jenkins CLI available, you can run:"
echo ""
echo "java -jar jenkins-cli.jar -s http://localhost:8080 create-credentials-by-xml system::system::jenkins _ < credentials.xml"
echo ""
echo "Where credentials.xml contains:"
echo ""
cat << EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>github-token</id>
  <description>GitHub Personal Access Token for manifests repository</description>
  <username>omarzaki222</username>
  <password>${GITHUB_TOKEN}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

echo ""
echo "✅ After adding the credentials:"
echo "1. The Jenkins pipeline will be able to push to the manifests repository"
echo "2. ArgoCD will automatically detect changes and deploy"
echo "3. Your CI/CD pipeline will be fully automated"
echo ""
echo "🔍 To verify credentials are working:"
echo "1. Run a Jenkins build"
echo "2. Check the 'Update Manifests Repository' stage"
echo "3. Verify the manifests repository gets updated with new image tags"