#!/bin/bash

# GitHub repository setup script
# This script helps you create a GitHub repository and push your code

set -e

echo "🚀 GitHub Repository Setup Script"
echo "================================="

# Check if git is configured
if ! git config --global user.name &> /dev/null; then
    echo "❌ Git user.name is not configured"
    echo "Please run: git config --global user.name 'Your Name'"
    exit 1
fi

if ! git config --global user.email &> /dev/null; then
    echo "❌ Git user.email is not configured"
    echo "Please run: git config --global user.email 'your.email@example.com'"
    exit 1
fi

echo "✅ Git is properly configured"

# Get repository information
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your repository name (default: end-to-end-python-app): " REPO_NAME
REPO_NAME=${REPO_NAME:-end-to-end-python-app}

echo ""
echo "Repository will be created as: $GITHUB_USERNAME/$REPO_NAME"
read -p "Is this correct? (y/n): " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Setup cancelled"
    exit 0
fi

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI found"
    
    # Check if user is authenticated
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI is authenticated"
        
        # Create repository
        echo "📦 Creating GitHub repository..."
        gh repo create $REPO_NAME --public --description "End-to-End Python Flask Application with Jenkins CI/CD and Kubernetes deployment"
        
        # Add remote origin
        echo "🔗 Adding remote origin..."
        git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
        
        # Push to GitHub
        echo "📤 Pushing code to GitHub..."
        git push -u origin main
        
        echo ""
        echo "🎉 Success! Your repository is now available at:"
        echo "https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        
    else
        echo "❌ GitHub CLI is not authenticated"
        echo "Please run: gh auth login"
        exit 1
    fi
    
else
    echo "⚠️  GitHub CLI not found"
    echo ""
    echo "Manual setup required:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a new repository named: $REPO_NAME"
    echo "3. Don't initialize with README (we already have one)"
    echo "4. Copy the repository URL"
    echo ""
    echo "Then run these commands:"
    echo "git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo "git push -u origin main"
    echo ""
    echo "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Update the repository URL in jenkins/pipeline-config.xml"
echo "2. Configure Jenkins with the required credentials"
echo "3. Set up webhooks for automatic builds (optional)"
echo "4. Test the pipeline with a manual build"
echo ""
echo "🔧 Required Jenkins Credentials:"
echo "- docker-hub-credentials (Docker Hub username/password)"
echo "- kubeconfig (Kubernetes configuration file)"
echo "- github-credentials (GitHub username/token)"
